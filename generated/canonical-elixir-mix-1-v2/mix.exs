defmodule Minigit.MixProject do
  use Mix.Project

  def project do
    [
      app: :minigit,
      version: "0.1.0",
      elixir: "~> 1.18",
      escript: [main_module: Minigit.Main],
      deps: []
    ]
  end
end
