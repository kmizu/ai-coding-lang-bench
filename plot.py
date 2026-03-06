#!/usr/bin/env python3
"""
Generate plots for the AI coding language benchmark.

Usage:
    python3 plot.py results/results.json
    python3 plot.py results/results.json --track canonical --tiers primary,secondary
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import numpy as np
import pandas as pd

plt.rcParams.update(
    {
        "figure.facecolor": "white",
        "axes.facecolor": "white",
        "axes.grid": True,
        "grid.alpha": 0.3,
        "font.size": 12,
    }
)

TIER_ORDER = {"primary": 0, "secondary": 1, "reference": 2, "legacy": 3}
TIER_COLOURS = {
    "primary": "#1f77b4",
    "secondary": "#ff7f0e",
    "reference": "#7f7f7f",
    "legacy": "#2ca02c",
}
DEFAULT_COLOUR = "#999999"


def load_results(path: Path) -> pd.DataFrame:
    with open(path) as f:
        raw = json.load(f)

    rows = []
    for record in raw:
        v1 = record.get("v1_claude") or {}
        v2 = record.get("v2_claude") or {}
        rows.append(
            {
                "track": record.get("track", "greenfield"),
                "tier": record.get("tier", "legacy"),
                "subject_id": record.get("subject_id", record.get("language", "unknown")),
                "subject_label": record.get("subject_label", record.get("language", "unknown").capitalize()),
                "trial": record["trial"],
                "v1_setup_time": record.get("v1_setup_time", 0),
                "v2_setup_time": record.get("v2_setup_time", 0),
                "v1_time": record.get("v1_time", 0),
                "v2_time": record.get("v2_time", 0),
                "total_setup_time": record.get("v1_setup_time", 0) + record.get("v2_setup_time", 0),
                "total_agent_time": record.get("v1_time", 0) + record.get("v2_time", 0),
                "v1_loc": record.get("v1_loc", 0),
                "v2_loc": record.get("v2_loc", 0),
                "v1_cost": v1.get("cost_usd", 0),
                "v2_cost": v2.get("cost_usd", 0),
                "total_cost": v1.get("cost_usd", 0) + v2.get("cost_usd", 0),
                "v1_turns": v1.get("num_turns", 0),
                "v2_turns": v2.get("num_turns", 0),
                "total_turns": v1.get("num_turns", 0) + v2.get("num_turns", 0),
            }
        )
    return pd.DataFrame(rows)


def ordered_subjects(df: pd.DataFrame, include_track_in_label: bool) -> list[str]:
    dedup = (
        df[["subject_id", "subject_label", "track", "tier"]]
        .drop_duplicates()
        .sort_values(
            by=["track", "tier", "subject_label"],
            key=lambda col: col.map(TIER_ORDER).fillna(9) if col.name == "tier" else col,
        )
    )
    labels = []
    for _, row in dedup.iterrows():
        label = row["subject_label"]
        if include_track_in_label:
            label = f"{label}\n[{row['track']}]"
        labels.append(label)
    return labels


def add_display_label(df: pd.DataFrame, include_track_in_label: bool) -> pd.DataFrame:
    df = df.copy()
    if include_track_in_label:
        df["display_label"] = df["subject_label"] + "\n[" + df["track"] + "]"
    else:
        df["display_label"] = df["subject_label"]
    return df


def boxdot(ax, df: pd.DataFrame, value_col: str, ylabel: str, title: str) -> None:
    labels = ordered_subjects(df, include_track_in_label=df["track"].nunique() > 1)
    positions = list(range(len(labels)))
    data = [df.loc[df["display_label"] == label, value_col].values for label in labels]

    bp = ax.boxplot(
        data,
        positions=positions,
        widths=0.5,
        patch_artist=True,
        showfliers=False,
        zorder=2,
    )
    for patch, label in zip(bp["boxes"], labels):
        tier = df.loc[df["display_label"] == label, "tier"].iloc[0]
        patch.set_facecolor(TIER_COLOURS.get(tier, DEFAULT_COLOUR))
        patch.set_alpha(0.35)
    for element in ("whiskers", "caps", "medians"):
        for line in bp[element]:
            line.set_color("#333333")
            line.set_linewidth(1.2)

    rng = np.random.default_rng(42)
    for pos, label in zip(positions, labels):
        tier = df.loc[df["display_label"] == label, "tier"].iloc[0]
        vals = df.loc[df["display_label"] == label, value_col].values
        jitter = rng.uniform(-0.15, 0.15, size=len(vals))
        ax.scatter(
            pos + jitter,
            vals,
            color=TIER_COLOURS.get(tier, DEFAULT_COLOUR),
            edgecolors="white",
            linewidths=0.5,
            s=50,
            alpha=0.85,
            zorder=3,
        )

    ax.set_ylim(bottom=0)
    ax.set_xticks(positions)
    ax.set_xticklabels(labels, rotation=30, ha="right")
    ax.set_ylabel(ylabel)
    ax.set_title(title, pad=15)


def save(fig, outdir: Path, name: str) -> None:
    path = outdir / f"{name}.png"
    fig.savefig(path, dpi=150, bbox_inches="tight")
    plt.close(fig)
    print(f"  saved {path}")


def scatter(ax, df: pd.DataFrame, x_col: str, y_col: str, title: str, ylabel: str) -> None:
    labels = ordered_subjects(df, include_track_in_label=df["track"].nunique() > 1)
    for label in labels:
      sub = df[df["display_label"] == label]
      tier = sub["tier"].iloc[0]
      ax.scatter(
          sub[x_col],
          sub[y_col],
          color=TIER_COLOURS.get(tier, DEFAULT_COLOUR),
          edgecolors="white",
          linewidths=0.5,
          s=60,
          alpha=0.85,
          label=label,
          zorder=3,
      )
    ax.set_xlabel("Agent Time (s)")
    ax.set_ylabel(ylabel)
    ax.set_xlim(left=0)
    ax.set_ylim(bottom=0)
    ax.set_title(title)
    ax.legend(fontsize=8, ncol=3, loc="upper left", framealpha=0.8, borderpad=0.5)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("json", type=Path, help="Path to results.json")
    parser.add_argument("-o", "--outdir", type=Path, default=Path("figures"), help="Output directory")
    parser.add_argument("--track", help="Filter to a specific track")
    parser.add_argument("--tiers", help="Comma-separated list of tiers to include")
    args = parser.parse_args()

    if not args.json.exists():
        sys.exit(f"Error: {args.json} not found")

    args.outdir.mkdir(parents=True, exist_ok=True)
    df = load_results(args.json)

    if args.track:
        df = df[df["track"] == args.track]
    if args.tiers:
        tiers = [tier.strip() for tier in args.tiers.split(",") if tier.strip()]
        df = df[df["tier"].isin(tiers)]

    if df.empty:
        sys.exit("No rows remain after filtering")

    df = add_display_label(df, include_track_in_label=df["track"].nunique() > 1)

    title_suffix = args.track if args.track else "all tracks"

    fig, ax = plt.subplots(figsize=(10, 5))
    boxdot(ax, df, "total_agent_time", ylabel="Agent Time (s)", title=f"MiniGit Agent Time (v1+v2, {title_suffix})")
    save(fig, args.outdir, "total_time")

    fig, ax = plt.subplots(figsize=(10, 5))
    boxdot(ax, df, "total_setup_time", ylabel="Setup Time (s)", title=f"MiniGit Setup Time (v1+v2, {title_suffix})")
    save(fig, args.outdir, "total_setup_time")

    fig, ax = plt.subplots(figsize=(10, 5))
    boxdot(ax, df, "total_cost", ylabel="Cost (USD)", title=f"MiniGit Cost (v1+v2, {title_suffix})")
    ax.yaxis.set_major_formatter(ticker.FormatStrFormatter("$%.2f"))
    save(fig, args.outdir, "total_cost")

    fig, ax = plt.subplots(figsize=(10, 5))
    boxdot(ax, df, "v2_loc", ylabel="Lines of Code", title=f"MiniGit LOC (v2, {title_suffix})")
    save(fig, args.outdir, "total_lines")

    fig, ax = plt.subplots(figsize=(10, 5))
    boxdot(ax, df, "v1_time", ylabel="Agent Time (s)", title=f"MiniGit Agent Time v1 ({title_suffix})")
    save(fig, args.outdir, "v1_time")

    fig, ax = plt.subplots(figsize=(10, 5))
    boxdot(ax, df, "v2_time", ylabel="Agent Time (s)", title=f"MiniGit Agent Time v2 ({title_suffix})")
    save(fig, args.outdir, "v2_time")

    fig, ax = plt.subplots(figsize=(10, 5))
    boxdot(ax, df, "v1_turns", ylabel="Turns", title=f"MiniGit Turns v1 ({title_suffix})")
    save(fig, args.outdir, "v1_turns")

    fig, ax = plt.subplots(figsize=(10, 5))
    boxdot(ax, df, "v2_turns", ylabel="Turns", title=f"MiniGit Turns v2 ({title_suffix})")
    save(fig, args.outdir, "v2_turns")

    fig, ax = plt.subplots(figsize=(10, 5))
    boxdot(ax, df, "total_turns", ylabel="Turns", title=f"MiniGit Turns (v1+v2, {title_suffix})")
    save(fig, args.outdir, "total_turns")

    fig, ax = plt.subplots(figsize=(8, 6))
    scatter(ax, df, "total_agent_time", "total_cost", title=f"Agent Time vs Cost ({title_suffix})", ylabel="Cost (USD)")
    ax.yaxis.set_major_formatter(ticker.FormatStrFormatter("$%.2f"))
    save(fig, args.outdir, "total_time_vs_cost")

    fig, ax = plt.subplots(figsize=(8, 6))
    scatter(ax, df, "total_agent_time", "v2_loc", title=f"Agent Time vs LOC ({title_suffix})", ylabel="Lines of Code")
    save(fig, args.outdir, "total_time_vs_loc")


if __name__ == "__main__":
    main()
