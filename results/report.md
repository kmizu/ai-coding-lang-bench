# AI Coding Language Benchmark Report

## Environment
- Date: 2026-03-08 04:03:54
- Claude Version: 2.1.71 (Claude Code)
- Last Run Track: canonical
- Last Run Seed: 4242

## Subjects
| Track | Tier | Subject | Version |
|-------|------|---------|---------|
| canonical | primary | Go / go | go version go1.26.0 linux/amd64 |
| canonical | primary | Java / Maven | Apache Maven 3.9.13 (39d686bd50d8e054301e3a68ad44781df6f80dda) / openjdk 25.0.1 2025-10-21 LTS |
| canonical | primary | Kotlin / Gradle | ------------------------------------------------------------ / Gradle 9.3.1 / openjdk 25.0.1 2025-10-21 LTS |
| canonical | primary | Python / uv | uv 0.10.8 / Python 3.14.2 |
| canonical | primary | Ruby / Bundler | Bundler version 2.6.2 / ruby 3.4.1 (2024-12-25 revision 48d4efcb85) +PRISM [x86_64-linux] |
| canonical | primary | Rust / Cargo | cargo 1.94.0 (85eff7c80 2026-01-15) / rustc 1.94.0 (4a4ef493e 2026-03-02) |
| canonical | primary | Scala / sbt | 1.12.5 / openjdk 25.0.1 2025-10-21 LTS |
| canonical | secondary | C# / dotnet | 9.0.311 |
| canonical | secondary | Clojure / Leiningen | Leiningen 2.12.0 on Java 25.0.1 OpenJDK 64-Bit Server VM |
| canonical | secondary | Elixir / Mix | Elixir 1.18.2 (compiled with Erlang/OTP 27) |
| canonical | secondary | F# / dotnet | 9.0.311 |
| canonical | secondary | Java / Gradle | ------------------------------------------------------------ / Gradle 9.3.1 / openjdk 25.0.1 2025-10-21 LTS |
| canonical | secondary | JavaScript / Node | v24.14.0 |
| canonical | secondary | PHP / Composer | PHP 8.1.2-1ubuntu2.23 (cli) (built: Jan  7 2026 08:37:41) (NTS) / Composer version 2.9.5 2026-01-29 11:40:53 |
| canonical | secondary | Python / pip | Python 3.14.2 / pip 25.3 from /home/linuxbrew/.linuxbrew/lib/python3.14/site-packages/pip (python 3.14) |
| canonical | secondary | Scala / sbt (server) | 1.12.5 / openjdk 25.0.1 2025-10-21 LTS |
| canonical | secondary | Scala 2.13 / sbt | 1.12.5 / openjdk 25.0.1 2025-10-21 LTS |
| canonical | secondary | VB.NET / dotnet | 9.0.311 |
| canonical | reference | PowerShell / raw | PowerShell 7.5.0 |
| canonical | reference | Prolog / SWI-Prolog | SWI-Prolog version 8.4.2 for x86_64-linux |
| greenfield | legacy | C | unknown |
| greenfield | legacy | Go | unknown |
| greenfield | legacy | Haskell | unknown |
| greenfield | legacy | Java | unknown |
| greenfield | legacy | Javascript | unknown |
| greenfield | legacy | Lua | unknown |
| greenfield | legacy | Ocaml | unknown |
| greenfield | legacy | Perl | unknown |
| greenfield | legacy | Python | unknown |
| greenfield | legacy | Python/mypy | unknown |
| greenfield | legacy | Ruby | unknown |
| greenfield | legacy | Ruby/steep | unknown |
| greenfield | legacy | Rust | unknown |
| greenfield | legacy | Scheme | unknown |
| greenfield | legacy | Typescript | unknown |

## Results Summary
| Track | Tier | Subject | Trials | Avg Setup | Avg Agent Time | Avg Cost | v1 Pass | v2 Pass | Avg LOC | Time/100L | Cost/100L |
|-------|------|---------|--------|-----------|----------------|----------|---------|---------|---------|-----------|-----------|
| canonical | primary | Go / go | 3 | 0.1s | 158.2s±33.8s | $0.00 | 3/3 (100%) | 3/3 (100%) | 375 | 42.19s | $0.0000 |
| canonical | primary | Java / Maven | 3 | 5.9s | 272.6s±40.5s | $0.00 | 3/3 (100%) | 3/3 (100%) | 271 | 100.59s | $0.0000 |
| canonical | primary | Kotlin / Gradle | 3 | 0.9s | 234.1s±9.9s | $0.00 | 3/3 (100%) | 3/3 (100%) | 264 | 88.67s | $0.0000 |
| canonical | primary | Python / uv | 1 | 4.5s | 173.8s±0.0s | $0.00 | 1/1 (100%) | 1/1 (100%) | 274 | 63.43s | $0.0000 |
| canonical | primary | Ruby / Bundler | 3 | 0.9s | 217.6s±31.5s | $0.00 | 3/3 (100%) | 3/3 (100%) | 272 | 80.00s | $0.0000 |
| canonical | primary | Rust / Cargo | 1 | 0.3s | 313.8s±0.0s | $0.00 | 1/1 (100%) | 0/1 (0%) | 4 | 7845.00s | $0.0000 |
| canonical | primary | Scala / sbt | 3 | 6.9s | 321.0s±42.6s | $0.00 | 3/3 (100%) | 3/3 (100%) | 256 | 125.39s | $0.0000 |
| canonical | secondary | C# / dotnet | 3 | 3.1s | 276.9s±47.7s | $0.00 | 3/3 (100%) | 3/3 (100%) | 353 | 78.44s | $0.0000 |
| canonical | secondary | Clojure / Leiningen | 3 | 2.4s | 392.8s±54.0s | $0.00 | 3/3 (100%) | 3/3 (100%) | 230 | 170.78s | $0.0000 |
| canonical | secondary | Elixir / Mix | 3 | 0.7s | 227.0s±35.9s | $0.00 | 3/3 (100%) | 3/3 (100%) | 271 | 83.76s | $0.0000 |
| canonical | secondary | F# / dotnet | 3 | 2.4s | 258.0s±22.9s | $0.00 | 3/3 (100%) | 3/3 (100%) | 256 | 100.78s | $0.0000 |
| canonical | secondary | Java / Gradle | 3 | 23.1s | 342.3s±80.0s | $0.00 | 3/3 (100%) | 3/3 (100%) | 328 | 104.36s | $0.0000 |
| canonical | secondary | JavaScript / Node | 3 | 0.1s | 170.2s±33.6s | $0.00 | 3/3 (100%) | 3/3 (100%) | 238 | 71.51s | $0.0000 |
| canonical | secondary | PHP / Composer | 3 | 0.8s | 383.1s±25.2s | $0.00 | 3/3 (100%) | 3/3 (100%) | 1340 | 28.59s | $0.0000 |
| canonical | secondary | Python / pip | 3 | 5.2s | 175.6s±36.7s | $0.00 | 3/3 (100%) | 3/3 (100%) | 267 | 65.77s | $0.0000 |
| canonical | secondary | Scala / sbt (server) | 3 | 7.9s | 323.1s±26.5s | $0.00 | 3/3 (100%) | 3/3 (100%) | 212 | 152.41s | $0.0000 |
| canonical | secondary | Scala 2.13 / sbt | 3 | 10.4s | 379.4s±65.0s | $0.00 | 3/3 (100%) | 3/3 (100%) | 239 | 158.74s | $0.0000 |
| canonical | secondary | VB.NET / dotnet | 3 | 2.0s | 294.5s±23.3s | $0.00 | 3/3 (100%) | 3/3 (100%) | 342 | 86.11s | $0.0000 |
| canonical | reference | PowerShell / raw | 3 | 0.1s | 698.1s±290.2s | $0.00 | 3/3 (100%) | 3/3 (100%) | 287 | 243.24s | $0.0000 |
| canonical | reference | Prolog / SWI-Prolog | 5 | 0.1s | 296.9s±276.7s | $0.00 | 3/5 (60%) | 3/5 (60%) | 196 | 151.48s | $0.0000 |
| greenfield | legacy | C | 20 | 0.0s | 155.8s±40.9s | $0.74 | 20/20 (100%) | 20/20 (100%) | 517 | 30.14s | $0.1430 |
| greenfield | legacy | Go | 20 | 0.0s | 101.6s±37.0s | $0.50 | 20/20 (100%) | 20/20 (100%) | 324 | 31.36s | $0.1531 |
| greenfield | legacy | Haskell | 20 | 0.0s | 174.0s±44.2s | $0.74 | 19/20 (95%) | 20/20 (100%) | 224 | 77.68s | $0.3301 |
| greenfield | legacy | Java | 20 | 0.0s | 115.4s±34.4s | $0.50 | 20/20 (100%) | 20/20 (100%) | 303 | 38.09s | $0.1661 |
| greenfield | legacy | Javascript | 20 | 0.0s | 81.1s±5.0s | $0.39 | 20/20 (100%) | 20/20 (100%) | 248 | 32.70s | $0.1564 |
| greenfield | legacy | Lua | 20 | 0.0s | 143.6s±43.0s | $0.58 | 20/20 (100%) | 20/20 (100%) | 398 | 36.08s | $0.1469 |
| greenfield | legacy | Ocaml | 20 | 0.0s | 128.1s±28.9s | $0.58 | 20/20 (100%) | 20/20 (100%) | 216 | 59.31s | $0.2692 |
| greenfield | legacy | Perl | 20 | 0.0s | 130.2s±44.2s | $0.55 | 20/20 (100%) | 20/20 (100%) | 315 | 41.33s | $0.1753 |
| greenfield | legacy | Python | 20 | 0.0s | 74.6s±4.5s | $0.38 | 20/20 (100%) | 20/20 (100%) | 235 | 31.74s | $0.1618 |
| greenfield | legacy | Python/mypy | 20 | 0.0s | 125.3s±19.0s | $0.57 | 20/20 (100%) | 20/20 (100%) | 326 | 38.44s | $0.1744 |
| greenfield | legacy | Ruby | 20 | 0.0s | 73.1s±4.2s | $0.36 | 20/20 (100%) | 20/20 (100%) | 219 | 33.38s | $0.1645 |
| greenfield | legacy | Ruby/steep | 20 | 0.0s | 186.6s±69.7s | $0.84 | 20/20 (100%) | 20/20 (100%) | 304 | 61.38s | $0.2764 |
| greenfield | legacy | Rust | 20 | 0.0s | 113.7s±54.8s | $0.54 | 19/20 (95%) | 19/20 (95%) | 303 | 37.52s | $0.1780 |
| greenfield | legacy | Scheme | 20 | 0.0s | 130.6s±39.9s | $0.60 | 20/20 (100%) | 20/20 (100%) | 310 | 42.13s | $0.1944 |
| greenfield | legacy | Typescript | 20 | 0.0s | 133.0s±29.4s | $0.62 | 20/20 (100%) | 20/20 (100%) | 310 | 42.90s | $0.1996 |

## Token Summary
| Track | Tier | Subject | Avg Input | Avg Output | Avg Cache Create | Avg Cache Read | Avg Total |
|-------|------|---------|-----------|------------|------------------|----------------|-----------|
| canonical | primary | Go / go | 28 | 7,547 | 80,741 | 553,902 | 642,218 |
| canonical | primary | Java / Maven | 33 | 10,743 | 86,046 | 691,459 | 788,282 |
| canonical | primary | Kotlin / Gradle | 1,946 | 9,473 | 88,702 | 767,970 | 868,091 |
| canonical | primary | Python / uv | 31 | 7,961 | 85,832 | 601,824 | 695,648 |
| canonical | primary | Ruby / Bundler | 29 | 7,737 | 81,869 | 505,968 | 595,604 |
| canonical | primary | Rust / Cargo | 200 | 7,059 | 83,446 | 596,282 | 686,987 |
| canonical | primary | Scala / sbt | 2,415 | 13,315 | 98,409 | 788,760 | 902,899 |
| canonical | secondary | C# / dotnet | 40 | 12,086 | 95,020 | 969,084 | 1,076,230 |
| canonical | secondary | Clojure / Leiningen | 977 | 12,511 | 91,791 | 725,536 | 830,814 |
| canonical | secondary | Elixir / Mix | 30 | 10,282 | 86,111 | 530,805 | 627,228 |
| canonical | secondary | F# / dotnet | 37 | 10,749 | 94,628 | 927,981 | 1,033,396 |
| canonical | secondary | Java / Gradle | 36 | 11,462 | 86,378 | 738,087 | 835,963 |
| canonical | secondary | JavaScript / Node | 23 | 7,632 | 79,809 | 370,875 | 458,339 |
| canonical | secondary | PHP / Composer | 29 | 21,714 | 97,957 | 563,490 | 683,190 |
| canonical | secondary | Python / pip | 34 | 8,060 | 103,302 | 804,313 | 915,709 |
| canonical | secondary | Scala / sbt (server) | 1,942 | 13,210 | 50,372 | 792,151 | 857,674 |
| canonical | secondary | Scala 2.13 / sbt | 3,057 | 14,430 | 120,495 | 852,588 | 990,569 |
| canonical | secondary | VB.NET / dotnet | 37 | 13,326 | 97,000 | 962,092 | 1,072,455 |
| canonical | reference | PowerShell / raw | 38 | 29,213 | 105,298 | 1,132,469 | 1,267,019 |
| canonical | reference | Prolog / SWI-Prolog | 17 | 19,315 | 61,928 | 352,686 | 433,946 |
| greenfield | legacy | C | 22 | 10,223 | 33,028 | 554,607 | 597,880 |
| greenfield | legacy | Go | 18 | 6,175 | 24,421 | 377,751 | 408,365 |
| greenfield | legacy | Haskell | 27 | 8,636 | 29,185 | 681,994 | 719,841 |
| greenfield | legacy | Java | 301 | 6,275 | 25,109 | 372,614 | 404,298 |
| greenfield | legacy | Javascript | 139 | 4,692 | 21,998 | 264,579 | 291,408 |
| greenfield | legacy | Lua | 19 | 8,085 | 28,126 | 413,003 | 449,233 |
| greenfield | legacy | Ocaml | 21 | 7,636 | 26,165 | 453,908 | 487,730 |
| greenfield | legacy | Perl | 18 | 7,792 | 27,452 | 371,364 | 406,625 |
| greenfield | legacy | Python | 15 | 4,564 | 21,606 | 262,243 | 288,427 |
| greenfield | legacy | Python/mypy | 21 | 7,451 | 23,772 | 467,464 | 498,709 |
| greenfield | legacy | Ruby | 139 | 4,035 | 21,112 | 253,371 | 278,657 |
| greenfield | legacy | Ruby/steep | 51 | 8,847 | 27,860 | 889,144 | 925,901 |
| greenfield | legacy | Rust | 19 | 7,060 | 25,955 | 401,289 | 434,323 |
| greenfield | legacy | Scheme | 20 | 7,496 | 29,834 | 457,419 | 494,769 |
| greenfield | legacy | Typescript | 23 | 6,385 | 29,896 | 544,131 | 580,435 |

## Full Results
| Track | Tier | Subject | Trial | Setup | Agent | v1 Tests | v2 Tests | Cost |
|-------|------|---------|-------|-------|-------|----------|----------|------|
| canonical | primary | Go / go | 1 | 0.1s | 138.7s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | primary | Go / go | 2 | 0.1s | 197.2s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | primary | Go / go | 3 | 0.2s | 138.6s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | primary | Java / Maven | 1 | 12.0s | 300.5s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | primary | Java / Maven | 2 | 2.9s | 226.2s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | primary | Java / Maven | 3 | 2.8s | 291.1s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | primary | Kotlin / Gradle | 1 | 0.9s | 226.1s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | primary | Kotlin / Gradle | 2 | 0.9s | 245.2s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | primary | Kotlin / Gradle | 3 | 0.9s | 231.0s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | primary | Python / uv | 1 | 4.5s | 173.8s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | primary | Ruby / Bundler | 1 | 1.7s | 254.0s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | primary | Ruby / Bundler | 2 | 0.6s | 200.6s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | primary | Ruby / Bundler | 3 | 0.3s | 198.3s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | primary | Rust / Cargo | 1 | 0.3s | 313.8s | 11/11 PASS | 0/0 FAIL | $0.00 |
| canonical | primary | Scala / sbt | 1 | 6.9s | 288.1s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | primary | Scala / sbt | 2 | 7.3s | 305.7s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | primary | Scala / sbt | 3 | 6.6s | 369.1s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | C# / dotnet | 1 | 3.3s | 300.3s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | C# / dotnet | 2 | 2.3s | 222.0s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | C# / dotnet | 3 | 3.8s | 308.4s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | Clojure / Leiningen | 1 | 4.6s | 335.7s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | Clojure / Leiningen | 2 | 1.2s | 443.0s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | Clojure / Leiningen | 3 | 1.3s | 399.6s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | Elixir / Mix | 1 | 0.7s | 248.3s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | Elixir / Mix | 2 | 0.7s | 247.1s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | Elixir / Mix | 3 | 0.6s | 185.5s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | F# / dotnet | 1 | 3.8s | 248.3s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | F# / dotnet | 2 | 1.7s | 284.2s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | F# / dotnet | 3 | 1.7s | 241.6s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | Java / Gradle | 1 | 63.7s | 258.9s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | Java / Gradle | 2 | 2.4s | 418.5s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | Java / Gradle | 3 | 3.3s | 349.4s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | JavaScript / Node | 1 | 0.2s | 165.0s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | JavaScript / Node | 2 | 0.1s | 139.4s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | JavaScript / Node | 3 | 0.1s | 206.1s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | PHP / Composer | 1 | 1.2s | 357.2s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | PHP / Composer | 2 | 0.5s | 407.5s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | PHP / Composer | 3 | 0.6s | 384.6s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | Python / pip | 1 | 5.3s | 217.7s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | Python / pip | 2 | 5.3s | 158.0s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | Python / pip | 3 | 5.1s | 151.0s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | Scala / sbt (server) | 1 | 6.9s | 348.1s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | Scala / sbt (server) | 2 | 7.1s | 295.4s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | Scala / sbt (server) | 3 | 9.6s | 325.8s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | Scala 2.13 / sbt | 1 | 6.6s | 418.1s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | Scala 2.13 / sbt | 2 | 8.2s | 304.4s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | Scala 2.13 / sbt | 3 | 16.4s | 415.7s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | VB.NET / dotnet | 1 | 2.0s | 319.9s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | VB.NET / dotnet | 2 | 2.4s | 289.5s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | secondary | VB.NET / dotnet | 3 | 1.7s | 274.0s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | reference | PowerShell / raw | 1 | 0.1s | 891.0s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | reference | PowerShell / raw | 2 | 0.1s | 838.9s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | reference | PowerShell / raw | 3 | 0.1s | 364.3s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | reference | Prolog / SWI-Prolog | 1 | 0.1s | 0.6s | 0/0 FAIL | 0/0 FAIL | $0.00 |
| canonical | reference | Prolog / SWI-Prolog | 1 | 0.1s | 0.6s | 0/0 FAIL | 0/0 FAIL | $0.00 |
| canonical | reference | Prolog / SWI-Prolog | 1 | 0.1s | 482.1s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | reference | Prolog / SWI-Prolog | 2 | 0.1s | 582.3s | 11/11 PASS | 30/30 PASS | $0.00 |
| canonical | reference | Prolog / SWI-Prolog | 3 | 0.1s | 418.9s | 11/11 PASS | 30/30 PASS | $0.00 |
| greenfield | legacy | C | 1 | 0s | 136.5s | 11/11 PASS | 30/30 PASS | $0.67 |
| greenfield | legacy | C | 2 | 0s | 153.8s | 11/11 PASS | 30/30 PASS | $0.66 |
| greenfield | legacy | C | 3 | 0s | 208.1s | 11/11 PASS | 30/30 PASS | $1.04 |
| greenfield | legacy | C | 4 | 0s | 214.9s | 11/11 PASS | 30/30 PASS | $0.92 |
| greenfield | legacy | C | 5 | 0s | 134.5s | 11/11 PASS | 30/30 PASS | $0.67 |
| greenfield | legacy | C | 6 | 0s | 141.1s | 11/11 PASS | 30/30 PASS | $0.66 |
| greenfield | legacy | C | 7 | 0s | 165.9s | 11/11 PASS | 30/30 PASS | $0.85 |
| greenfield | legacy | C | 8 | 0s | 128.0s | 11/11 PASS | 30/30 PASS | $0.64 |
| greenfield | legacy | C | 9 | 0s | 182.1s | 11/11 PASS | 30/30 PASS | $0.80 |
| greenfield | legacy | C | 10 | 0s | 139.6s | 11/11 PASS | 30/30 PASS | $0.65 |
| greenfield | legacy | C | 11 | 0s | 157.9s | 11/11 PASS | 30/30 PASS | $0.79 |
| greenfield | legacy | C | 12 | 0s | 136.1s | 11/11 PASS | 30/30 PASS | $0.66 |
| greenfield | legacy | C | 13 | 0s | 135.7s | 11/11 PASS | 30/30 PASS | $0.67 |
| greenfield | legacy | C | 14 | 0s | 133.4s | 11/11 PASS | 30/30 PASS | $0.70 |
| greenfield | legacy | C | 15 | 0s | 124.8s | 11/11 PASS | 30/30 PASS | $0.63 |
| greenfield | legacy | C | 16 | 0s | 167.0s | 11/11 PASS | 30/30 PASS | $0.76 |
| greenfield | legacy | C | 17 | 0s | 120.1s | 11/11 PASS | 30/30 PASS | $0.59 |
| greenfield | legacy | C | 18 | 0s | 129.0s | 11/11 PASS | 30/30 PASS | $0.67 |
| greenfield | legacy | C | 19 | 0s | 121.1s | 11/11 PASS | 30/30 PASS | $0.60 |
| greenfield | legacy | C | 20 | 0s | 286.4s | 11/11 PASS | 30/30 PASS | $1.16 |
| greenfield | legacy | Go | 1 | 0s | 245.6s | 11/11 PASS | 30/30 PASS | $0.99 |
| greenfield | legacy | Go | 2 | 0s | 99.9s | 11/11 PASS | 30/30 PASS | $0.44 |
| greenfield | legacy | Go | 3 | 0s | 122.9s | 11/11 PASS | 30/30 PASS | $0.59 |
| greenfield | legacy | Go | 4 | 0s | 106.2s | 11/11 PASS | 30/30 PASS | $0.54 |
| greenfield | legacy | Go | 5 | 0s | 91.6s | 11/11 PASS | 30/30 PASS | $0.50 |
| greenfield | legacy | Go | 6 | 0s | 85.7s | 11/11 PASS | 30/30 PASS | $0.46 |
| greenfield | legacy | Go | 7 | 0s | 84.3s | 11/11 PASS | 30/30 PASS | $0.43 |
| greenfield | legacy | Go | 8 | 0s | 87.8s | 11/11 PASS | 30/30 PASS | $0.42 |
| greenfield | legacy | Go | 9 | 0s | 95.7s | 11/11 PASS | 30/30 PASS | $0.48 |
| greenfield | legacy | Go | 10 | 0s | 140.1s | 11/11 PASS | 30/30 PASS | $0.48 |
| greenfield | legacy | Go | 11 | 0s | 87.7s | 11/11 PASS | 30/30 PASS | $0.47 |
| greenfield | legacy | Go | 12 | 0s | 77.5s | 11/11 PASS | 30/30 PASS | $0.42 |
| greenfield | legacy | Go | 13 | 0s | 86.6s | 11/11 PASS | 30/30 PASS | $0.48 |
| greenfield | legacy | Go | 14 | 0s | 91.3s | 11/11 PASS | 30/30 PASS | $0.48 |
| greenfield | legacy | Go | 15 | 0s | 81.7s | 11/11 PASS | 30/30 PASS | $0.46 |
| greenfield | legacy | Go | 16 | 0s | 87.8s | 11/11 PASS | 30/30 PASS | $0.46 |
| greenfield | legacy | Go | 17 | 0s | 92.2s | 11/11 PASS | 30/30 PASS | $0.45 |
| greenfield | legacy | Go | 18 | 0s | 97.4s | 11/11 PASS | 30/30 PASS | $0.49 |
| greenfield | legacy | Go | 19 | 0s | 78.6s | 11/11 PASS | 30/30 PASS | $0.41 |
| greenfield | legacy | Go | 20 | 0s | 91.6s | 11/11 PASS | 30/30 PASS | $0.48 |
| greenfield | legacy | Haskell | 1 | 0s | 229.7s | 11/11 PASS | 30/30 PASS | $1.03 |
| greenfield | legacy | Haskell | 2 | 0s | 209.5s | 11/11 PASS | 30/30 PASS | $0.65 |
| greenfield | legacy | Haskell | 3 | 0s | 269.6s | 11/11 PASS | 30/30 PASS | $1.00 |
| greenfield | legacy | Haskell | 4 | 0s | 159.0s | 11/11 PASS | 30/30 PASS | $0.74 |
| greenfield | legacy | Haskell | 5 | 0s | 109.5s | 11/11 PASS | 30/30 PASS | $0.53 |
| greenfield | legacy | Haskell | 6 | 0s | 170.2s | 0/0 FAIL | 30/30 PASS | $0.90 |
| greenfield | legacy | Haskell | 7 | 0s | 168.3s | 11/11 PASS | 30/30 PASS | $0.90 |
| greenfield | legacy | Haskell | 8 | 0s | 124.8s | 11/11 PASS | 30/30 PASS | $0.54 |
| greenfield | legacy | Haskell | 9 | 0s | 177.6s | 11/11 PASS | 30/30 PASS | $0.87 |
| greenfield | legacy | Haskell | 10 | 0s | 190.2s | 11/11 PASS | 30/30 PASS | $0.92 |
| greenfield | legacy | Haskell | 11 | 0s | 157.6s | 11/11 PASS | 30/30 PASS | $0.84 |
| greenfield | legacy | Haskell | 12 | 0s | 162.2s | 11/11 PASS | 30/30 PASS | $0.77 |
| greenfield | legacy | Haskell | 13 | 0s | 225.0s | 11/11 PASS | 30/30 PASS | $0.52 |
| greenfield | legacy | Haskell | 14 | 0s | 172.9s | 11/11 PASS | 30/30 PASS | $0.73 |
| greenfield | legacy | Haskell | 15 | 0s | 179.9s | 11/11 PASS | 30/30 PASS | $0.91 |
| greenfield | legacy | Haskell | 16 | 0s | 249.9s | 11/11 PASS | 30/30 PASS | $0.62 |
| greenfield | legacy | Haskell | 17 | 0s | 132.6s | 11/11 PASS | 30/30 PASS | $0.59 |
| greenfield | legacy | Haskell | 18 | 0s | 139.9s | 11/11 PASS | 30/30 PASS | $0.55 |
| greenfield | legacy | Haskell | 19 | 0s | 133.4s | 11/11 PASS | 30/30 PASS | $0.65 |
| greenfield | legacy | Haskell | 20 | 0s | 117.9s | 11/11 PASS | 30/30 PASS | $0.51 |
| greenfield | legacy | Java | 1 | 0s | 191.2s | 11/11 PASS | 30/30 PASS | $0.64 |
| greenfield | legacy | Java | 2 | 0s | 172.3s | 11/11 PASS | 30/30 PASS | $0.71 |
| greenfield | legacy | Java | 3 | 0s | 105.6s | 11/11 PASS | 30/30 PASS | $0.53 |
| greenfield | legacy | Java | 4 | 0s | 131.4s | 11/11 PASS | 30/30 PASS | $0.59 |
| greenfield | legacy | Java | 5 | 0s | 99.2s | 11/11 PASS | 30/30 PASS | $0.46 |
| greenfield | legacy | Java | 6 | 0s | 110.0s | 11/11 PASS | 30/30 PASS | $0.49 |
| greenfield | legacy | Java | 7 | 0s | 94.0s | 11/11 PASS | 30/30 PASS | $0.45 |
| greenfield | legacy | Java | 8 | 0s | 100.5s | 11/11 PASS | 30/30 PASS | $0.47 |
| greenfield | legacy | Java | 9 | 0s | 106.0s | 11/11 PASS | 30/30 PASS | $0.52 |
| greenfield | legacy | Java | 10 | 0s | 99.3s | 11/11 PASS | 30/30 PASS | $0.51 |
| greenfield | legacy | Java | 11 | 0s | 104.2s | 11/11 PASS | 30/30 PASS | $0.51 |
| greenfield | legacy | Java | 12 | 0s | 91.7s | 11/11 PASS | 30/30 PASS | $0.46 |
| greenfield | legacy | Java | 13 | 0s | 103.5s | 11/11 PASS | 30/30 PASS | $0.53 |
| greenfield | legacy | Java | 14 | 0s | 207.2s | 11/11 PASS | 30/30 PASS | $0.45 |
| greenfield | legacy | Java | 15 | 0s | 96.7s | 11/11 PASS | 30/30 PASS | $0.46 |
| greenfield | legacy | Java | 16 | 0s | 121.7s | 11/11 PASS | 30/30 PASS | $0.53 |
| greenfield | legacy | Java | 17 | 0s | 89.0s | 11/11 PASS | 30/30 PASS | $0.45 |
| greenfield | legacy | Java | 18 | 0s | 109.1s | 11/11 PASS | 30/30 PASS | $0.44 |
| greenfield | legacy | Java | 19 | 0s | 89.1s | 11/11 PASS | 30/30 PASS | $0.41 |
| greenfield | legacy | Java | 20 | 0s | 86.9s | 11/11 PASS | 30/30 PASS | $0.45 |
| greenfield | legacy | Javascript | 1 | 0s | 88.3s | 11/11 PASS | 30/30 PASS | $0.43 |
| greenfield | legacy | Javascript | 2 | 0s | 92.8s | 11/11 PASS | 30/30 PASS | $0.44 |
| greenfield | legacy | Javascript | 3 | 0s | 79.4s | 11/11 PASS | 30/30 PASS | $0.39 |
| greenfield | legacy | Javascript | 4 | 0s | 90.0s | 11/11 PASS | 30/30 PASS | $0.38 |
| greenfield | legacy | Javascript | 5 | 0s | 79.6s | 11/11 PASS | 30/30 PASS | $0.40 |
| greenfield | legacy | Javascript | 6 | 0s | 84.0s | 11/11 PASS | 30/30 PASS | $0.41 |
| greenfield | legacy | Javascript | 7 | 0s | 77.4s | 11/11 PASS | 30/30 PASS | $0.37 |
| greenfield | legacy | Javascript | 8 | 0s | 79.0s | 11/11 PASS | 30/30 PASS | $0.40 |
| greenfield | legacy | Javascript | 9 | 0s | 82.2s | 11/11 PASS | 30/30 PASS | $0.39 |
| greenfield | legacy | Javascript | 10 | 0s | 82.7s | 11/11 PASS | 30/30 PASS | $0.40 |
| greenfield | legacy | Javascript | 11 | 0s | 79.2s | 11/11 PASS | 30/30 PASS | $0.35 |
| greenfield | legacy | Javascript | 12 | 0s | 80.2s | 11/11 PASS | 30/30 PASS | $0.39 |
| greenfield | legacy | Javascript | 13 | 0s | 77.4s | 11/11 PASS | 30/30 PASS | $0.40 |
| greenfield | legacy | Javascript | 14 | 0s | 75.9s | 11/11 PASS | 30/30 PASS | $0.39 |
| greenfield | legacy | Javascript | 15 | 0s | 82.4s | 11/11 PASS | 30/30 PASS | $0.36 |
| greenfield | legacy | Javascript | 16 | 0s | 77.5s | 11/11 PASS | 30/30 PASS | $0.37 |
| greenfield | legacy | Javascript | 17 | 0s | 81.4s | 11/11 PASS | 30/30 PASS | $0.36 |
| greenfield | legacy | Javascript | 18 | 0s | 72.6s | 11/11 PASS | 30/30 PASS | $0.37 |
| greenfield | legacy | Javascript | 19 | 0s | 84.6s | 11/11 PASS | 30/30 PASS | $0.39 |
| greenfield | legacy | Javascript | 20 | 0s | 75.9s | 11/11 PASS | 30/30 PASS | $0.37 |
| greenfield | legacy | Lua | 1 | 0s | 106.8s | 11/11 PASS | 30/30 PASS | $0.49 |
| greenfield | legacy | Lua | 2 | 0s | 144.5s | 11/11 PASS | 30/30 PASS | $0.56 |
| greenfield | legacy | Lua | 3 | 0s | 234.2s | 11/11 PASS | 30/30 PASS | $0.76 |
| greenfield | legacy | Lua | 4 | 0s | 160.8s | 11/11 PASS | 30/30 PASS | $0.61 |
| greenfield | legacy | Lua | 5 | 0s | 146.4s | 11/11 PASS | 30/30 PASS | $0.65 |
| greenfield | legacy | Lua | 6 | 0s | 164.9s | 11/11 PASS | 30/30 PASS | $0.72 |
| greenfield | legacy | Lua | 7 | 0s | 128.6s | 11/11 PASS | 30/30 PASS | $0.57 |
| greenfield | legacy | Lua | 8 | 0s | 112.4s | 11/11 PASS | 30/30 PASS | $0.52 |
| greenfield | legacy | Lua | 9 | 0s | 92.0s | 11/11 PASS | 30/30 PASS | $0.41 |
| greenfield | legacy | Lua | 10 | 0s | 123.1s | 11/11 PASS | 30/30 PASS | $0.57 |
| greenfield | legacy | Lua | 11 | 0s | 115.6s | 11/11 PASS | 30/30 PASS | $0.48 |
| greenfield | legacy | Lua | 12 | 0s | 271.0s | 11/11 PASS | 30/30 PASS | $0.69 |
| greenfield | legacy | Lua | 13 | 0s | 132.8s | 11/11 PASS | 30/30 PASS | $0.58 |
| greenfield | legacy | Lua | 14 | 0s | 145.2s | 11/11 PASS | 30/30 PASS | $0.60 |
| greenfield | legacy | Lua | 15 | 0s | 127.0s | 11/11 PASS | 30/30 PASS | $0.62 |
| greenfield | legacy | Lua | 16 | 0s | 108.0s | 11/11 PASS | 30/30 PASS | $0.50 |
| greenfield | legacy | Lua | 17 | 0s | 124.7s | 11/11 PASS | 30/30 PASS | $0.57 |
| greenfield | legacy | Lua | 18 | 0s | 113.5s | 11/11 PASS | 30/30 PASS | $0.50 |
| greenfield | legacy | Lua | 19 | 0s | 164.8s | 11/11 PASS | 30/30 PASS | $0.63 |
| greenfield | legacy | Lua | 20 | 0s | 155.6s | 11/11 PASS | 30/30 PASS | $0.66 |
| greenfield | legacy | Ocaml | 1 | 0s | 165.5s | 11/11 PASS | 30/30 PASS | $0.68 |
| greenfield | legacy | Ocaml | 2 | 0s | 182.0s | 11/11 PASS | 30/30 PASS | $0.75 |
| greenfield | legacy | Ocaml | 3 | 0s | 209.0s | 11/11 PASS | 30/30 PASS | $0.82 |
| greenfield | legacy | Ocaml | 4 | 0s | 120.5s | 11/11 PASS | 30/30 PASS | $0.54 |
| greenfield | legacy | Ocaml | 5 | 0s | 127.7s | 11/11 PASS | 30/30 PASS | $0.61 |
| greenfield | legacy | Ocaml | 6 | 0s | 121.1s | 11/11 PASS | 30/30 PASS | $0.59 |
| greenfield | legacy | Ocaml | 7 | 0s | 106.7s | 11/11 PASS | 30/30 PASS | $0.56 |
| greenfield | legacy | Ocaml | 8 | 0s | 109.7s | 11/11 PASS | 30/30 PASS | $0.51 |
| greenfield | legacy | Ocaml | 9 | 0s | 114.5s | 11/11 PASS | 30/30 PASS | $0.57 |
| greenfield | legacy | Ocaml | 10 | 0s | 108.6s | 11/11 PASS | 30/30 PASS | $0.54 |
| greenfield | legacy | Ocaml | 11 | 0s | 123.9s | 11/11 PASS | 30/30 PASS | $0.58 |
| greenfield | legacy | Ocaml | 12 | 0s | 131.3s | 11/11 PASS | 30/30 PASS | $0.58 |
| greenfield | legacy | Ocaml | 13 | 0s | 118.3s | 11/11 PASS | 30/30 PASS | $0.58 |
| greenfield | legacy | Ocaml | 14 | 0s | 128.3s | 11/11 PASS | 30/30 PASS | $0.54 |
| greenfield | legacy | Ocaml | 15 | 0s | 107.7s | 11/11 PASS | 30/30 PASS | $0.54 |
| greenfield | legacy | Ocaml | 16 | 0s | 112.5s | 11/11 PASS | 30/30 PASS | $0.53 |
| greenfield | legacy | Ocaml | 17 | 0s | 103.3s | 11/11 PASS | 30/30 PASS | $0.54 |
| greenfield | legacy | Ocaml | 18 | 0s | 161.0s | 11/11 PASS | 30/30 PASS | $0.55 |
| greenfield | legacy | Ocaml | 19 | 0s | 101.3s | 11/11 PASS | 30/30 PASS | $0.47 |
| greenfield | legacy | Ocaml | 20 | 0s | 108.5s | 11/11 PASS | 30/30 PASS | $0.54 |
| greenfield | legacy | Perl | 1 | 0s | 165.5s | 11/11 PASS | 30/30 PASS | $0.57 |
| greenfield | legacy | Perl | 2 | 0s | 185.2s | 11/11 PASS | 30/30 PASS | $0.60 |
| greenfield | legacy | Perl | 3 | 0s | 189.5s | 11/11 PASS | 30/30 PASS | $0.65 |
| greenfield | legacy | Perl | 4 | 0s | 94.7s | 11/11 PASS | 30/30 PASS | $0.47 |
| greenfield | legacy | Perl | 5 | 0s | 106.4s | 11/11 PASS | 30/30 PASS | $0.50 |
| greenfield | legacy | Perl | 6 | 0s | 118.0s | 11/11 PASS | 30/30 PASS | $0.58 |
| greenfield | legacy | Perl | 7 | 0s | 96.2s | 11/11 PASS | 30/30 PASS | $0.47 |
| greenfield | legacy | Perl | 8 | 0s | 85.7s | 11/11 PASS | 30/30 PASS | $0.40 |
| greenfield | legacy | Perl | 9 | 0s | 111.8s | 11/11 PASS | 30/30 PASS | $0.52 |
| greenfield | legacy | Perl | 10 | 0s | 136.7s | 11/11 PASS | 30/30 PASS | $0.58 |
| greenfield | legacy | Perl | 11 | 0s | 135.0s | 11/11 PASS | 30/30 PASS | $0.54 |
| greenfield | legacy | Perl | 12 | 0s | 270.8s | 11/11 PASS | 30/30 PASS | $1.03 |
| greenfield | legacy | Perl | 13 | 0s | 133.2s | 11/11 PASS | 30/30 PASS | $0.61 |
| greenfield | legacy | Perl | 14 | 0s | 95.5s | 11/11 PASS | 30/30 PASS | $0.46 |
| greenfield | legacy | Perl | 15 | 0s | 106.9s | 11/11 PASS | 30/30 PASS | $0.50 |
| greenfield | legacy | Perl | 16 | 0s | 124.7s | 11/11 PASS | 30/30 PASS | $0.53 |
| greenfield | legacy | Perl | 17 | 0s | 96.5s | 11/11 PASS | 30/30 PASS | $0.45 |
| greenfield | legacy | Perl | 18 | 0s | 103.0s | 11/11 PASS | 30/30 PASS | $0.47 |
| greenfield | legacy | Perl | 19 | 0s | 136.1s | 11/11 PASS | 30/30 PASS | $0.62 |
| greenfield | legacy | Perl | 20 | 0s | 112.2s | 11/11 PASS | 30/30 PASS | $0.51 |
| greenfield | legacy | Python | 1 | 0s | 73.6s | 11/11 PASS | 30/30 PASS | $0.38 |
| greenfield | legacy | Python | 2 | 0s | 75.8s | 11/11 PASS | 30/30 PASS | $0.37 |
| greenfield | legacy | Python | 3 | 0s | 80.4s | 11/11 PASS | 30/30 PASS | $0.40 |
| greenfield | legacy | Python | 4 | 0s | 71.5s | 11/11 PASS | 30/30 PASS | $0.38 |
| greenfield | legacy | Python | 5 | 0s | 75.3s | 11/11 PASS | 30/30 PASS | $0.36 |
| greenfield | legacy | Python | 6 | 0s | 72.6s | 11/11 PASS | 30/30 PASS | $0.36 |
| greenfield | legacy | Python | 7 | 0s | 69.8s | 11/11 PASS | 30/30 PASS | $0.36 |
| greenfield | legacy | Python | 8 | 0s | 69.1s | 11/11 PASS | 30/30 PASS | $0.36 |
| greenfield | legacy | Python | 9 | 0s | 74.3s | 11/11 PASS | 30/30 PASS | $0.39 |
| greenfield | legacy | Python | 10 | 0s | 84.8s | 11/11 PASS | 30/30 PASS | $0.40 |
| greenfield | legacy | Python | 11 | 0s | 76.5s | 11/11 PASS | 30/30 PASS | $0.40 |
| greenfield | legacy | Python | 12 | 0s | 81.9s | 11/11 PASS | 30/30 PASS | $0.43 |
| greenfield | legacy | Python | 13 | 0s | 73.9s | 11/11 PASS | 30/30 PASS | $0.40 |
| greenfield | legacy | Python | 14 | 0s | 70.7s | 11/11 PASS | 30/30 PASS | $0.39 |
| greenfield | legacy | Python | 15 | 0s | 76.6s | 11/11 PASS | 30/30 PASS | $0.37 |
| greenfield | legacy | Python | 16 | 0s | 78.9s | 11/11 PASS | 30/30 PASS | $0.42 |
| greenfield | legacy | Python | 17 | 0s | 68.2s | 11/11 PASS | 30/30 PASS | $0.36 |
| greenfield | legacy | Python | 18 | 0s | 76.7s | 11/11 PASS | 30/30 PASS | $0.35 |
| greenfield | legacy | Python | 19 | 0s | 68.5s | 11/11 PASS | 30/30 PASS | $0.36 |
| greenfield | legacy | Python | 20 | 0s | 73.6s | 11/11 PASS | 30/30 PASS | $0.36 |
| greenfield | legacy | Python/mypy | 1 | 0s | 135.7s | 11/11 PASS | 30/30 PASS | $0.63 |
| greenfield | legacy | Python/mypy | 2 | 0s | 120.0s | 11/11 PASS | 30/30 PASS | $0.51 |
| greenfield | legacy | Python/mypy | 3 | 0s | 142.5s | 11/11 PASS | 30/30 PASS | $0.73 |
| greenfield | legacy | Python/mypy | 4 | 0s | 91.0s | 11/11 PASS | 30/30 PASS | $0.47 |
| greenfield | legacy | Python/mypy | 5 | 0s | 126.5s | 11/11 PASS | 30/30 PASS | $0.64 |
| greenfield | legacy | Python/mypy | 6 | 0s | 129.1s | 11/11 PASS | 30/30 PASS | $0.60 |
| greenfield | legacy | Python/mypy | 7 | 0s | 141.5s | 11/11 PASS | 30/30 PASS | $0.66 |
| greenfield | legacy | Python/mypy | 8 | 0s | 110.2s | 11/11 PASS | 30/30 PASS | $0.50 |
| greenfield | legacy | Python/mypy | 9 | 0s | 138.0s | 11/11 PASS | 30/30 PASS | $0.67 |
| greenfield | legacy | Python/mypy | 10 | 0s | 111.1s | 11/11 PASS | 30/30 PASS | $0.51 |
| greenfield | legacy | Python/mypy | 11 | 0s | 179.8s | 11/11 PASS | 30/30 PASS | $0.59 |
| greenfield | legacy | Python/mypy | 12 | 0s | 116.5s | 11/11 PASS | 30/30 PASS | $0.57 |
| greenfield | legacy | Python/mypy | 13 | 0s | 114.0s | 11/11 PASS | 30/30 PASS | $0.59 |
| greenfield | legacy | Python/mypy | 14 | 0s | 113.6s | 11/11 PASS | 30/30 PASS | $0.49 |
| greenfield | legacy | Python/mypy | 15 | 0s | 128.3s | 11/11 PASS | 30/30 PASS | $0.57 |
| greenfield | legacy | Python/mypy | 16 | 0s | 125.6s | 11/11 PASS | 30/30 PASS | $0.49 |
| greenfield | legacy | Python/mypy | 17 | 0s | 115.4s | 11/11 PASS | 30/30 PASS | $0.49 |
| greenfield | legacy | Python/mypy | 18 | 0s | 144.9s | 11/11 PASS | 30/30 PASS | $0.56 |
| greenfield | legacy | Python/mypy | 19 | 0s | 102.6s | 11/11 PASS | 30/30 PASS | $0.52 |
| greenfield | legacy | Python/mypy | 20 | 0s | 119.0s | 11/11 PASS | 30/30 PASS | $0.58 |
| greenfield | legacy | Ruby | 1 | 0s | 75.3s | 11/11 PASS | 30/30 PASS | $0.36 |
| greenfield | legacy | Ruby | 2 | 0s | 81.3s | 11/11 PASS | 30/30 PASS | $0.38 |
| greenfield | legacy | Ruby | 3 | 0s | 72.6s | 11/11 PASS | 30/30 PASS | $0.36 |
| greenfield | legacy | Ruby | 4 | 0s | 70.5s | 11/11 PASS | 30/30 PASS | $0.36 |
| greenfield | legacy | Ruby | 5 | 0s | 76.6s | 11/11 PASS | 30/30 PASS | $0.36 |
| greenfield | legacy | Ruby | 6 | 0s | 67.7s | 11/11 PASS | 30/30 PASS | $0.36 |
| greenfield | legacy | Ruby | 7 | 0s | 72.4s | 11/11 PASS | 30/30 PASS | $0.36 |
| greenfield | legacy | Ruby | 8 | 0s | 66.7s | 11/11 PASS | 30/30 PASS | $0.31 |
| greenfield | legacy | Ruby | 9 | 0s | 72.5s | 11/11 PASS | 30/30 PASS | $0.37 |
| greenfield | legacy | Ruby | 10 | 0s | 78.5s | 11/11 PASS | 30/30 PASS | $0.37 |
| greenfield | legacy | Ruby | 11 | 0s | 71.6s | 11/11 PASS | 30/30 PASS | $0.32 |
| greenfield | legacy | Ruby | 12 | 0s | 78.4s | 11/11 PASS | 30/30 PASS | $0.39 |
| greenfield | legacy | Ruby | 13 | 0s | 75.2s | 11/11 PASS | 30/30 PASS | $0.38 |
| greenfield | legacy | Ruby | 14 | 0s | 66.9s | 11/11 PASS | 30/30 PASS | $0.34 |
| greenfield | legacy | Ruby | 15 | 0s | 71.2s | 11/11 PASS | 30/30 PASS | $0.36 |
| greenfield | legacy | Ruby | 16 | 0s | 73.1s | 11/11 PASS | 30/30 PASS | $0.36 |
| greenfield | legacy | Ruby | 17 | 0s | 76.8s | 11/11 PASS | 30/30 PASS | $0.36 |
| greenfield | legacy | Ruby | 18 | 0s | 77.7s | 11/11 PASS | 30/30 PASS | $0.39 |
| greenfield | legacy | Ruby | 19 | 0s | 67.6s | 11/11 PASS | 30/30 PASS | $0.36 |
| greenfield | legacy | Ruby | 20 | 0s | 70.3s | 11/11 PASS | 30/30 PASS | $0.37 |
| greenfield | legacy | Ruby/steep | 1 | 0s | 474.4s | 11/11 PASS | 30/30 PASS | $0.88 |
| greenfield | legacy | Ruby/steep | 2 | 0s | 200.3s | 11/11 PASS | 30/30 PASS | $0.84 |
| greenfield | legacy | Ruby/steep | 3 | 0s | 180.0s | 11/11 PASS | 30/30 PASS | $0.87 |
| greenfield | legacy | Ruby/steep | 4 | 0s | 184.3s | 11/11 PASS | 30/30 PASS | $0.92 |
| greenfield | legacy | Ruby/steep | 5 | 0s | 150.6s | 11/11 PASS | 30/30 PASS | $0.70 |
| greenfield | legacy | Ruby/steep | 6 | 0s | 189.7s | 11/11 PASS | 30/30 PASS | $0.88 |
| greenfield | legacy | Ruby/steep | 7 | 0s | 172.0s | 11/11 PASS | 30/30 PASS | $0.86 |
| greenfield | legacy | Ruby/steep | 8 | 0s | 173.4s | 11/11 PASS | 30/30 PASS | $0.88 |
| greenfield | legacy | Ruby/steep | 9 | 0s | 194.1s | 11/11 PASS | 30/30 PASS | $0.99 |
| greenfield | legacy | Ruby/steep | 10 | 0s | 177.4s | 11/11 PASS | 30/30 PASS | $0.85 |
| greenfield | legacy | Ruby/steep | 11 | 0s | 158.2s | 11/11 PASS | 30/30 PASS | $0.79 |
| greenfield | legacy | Ruby/steep | 12 | 0s | 153.1s | 11/11 PASS | 30/30 PASS | $0.78 |
| greenfield | legacy | Ruby/steep | 13 | 0s | 153.3s | 11/11 PASS | 30/30 PASS | $0.83 |
| greenfield | legacy | Ruby/steep | 14 | 0s | 155.8s | 11/11 PASS | 30/30 PASS | $0.80 |
| greenfield | legacy | Ruby/steep | 15 | 0s | 164.0s | 11/11 PASS | 30/30 PASS | $0.85 |
| greenfield | legacy | Ruby/steep | 16 | 0s | 172.2s | 11/11 PASS | 30/30 PASS | $0.84 |
| greenfield | legacy | Ruby/steep | 17 | 0s | 163.1s | 11/11 PASS | 30/30 PASS | $0.72 |
| greenfield | legacy | Ruby/steep | 18 | 0s | 152.4s | 11/11 PASS | 30/30 PASS | $0.73 |
| greenfield | legacy | Ruby/steep | 19 | 0s | 204.4s | 11/11 PASS | 30/30 PASS | $1.03 |
| greenfield | legacy | Ruby/steep | 20 | 0s | 159.5s | 11/11 PASS | 30/30 PASS | $0.74 |
| greenfield | legacy | Rust | 1 | 0s | 335.7s | 10/11 FAIL | 29/30 FAIL | $1.14 |
| greenfield | legacy | Rust | 2 | 0s | 125.8s | 11/11 PASS | 30/30 PASS | $0.62 |
| greenfield | legacy | Rust | 3 | 0s | 133.2s | 11/11 PASS | 30/30 PASS | $0.68 |
| greenfield | legacy | Rust | 4 | 0s | 115.6s | 11/11 PASS | 30/30 PASS | $0.59 |
| greenfield | legacy | Rust | 5 | 0s | 132.9s | 11/11 PASS | 30/30 PASS | $0.61 |
| greenfield | legacy | Rust | 6 | 0s | 88.5s | 11/11 PASS | 30/30 PASS | $0.45 |
| greenfield | legacy | Rust | 7 | 0s | 103.7s | 11/11 PASS | 30/30 PASS | $0.49 |
| greenfield | legacy | Rust | 8 | 0s | 86.2s | 11/11 PASS | 30/30 PASS | $0.43 |
| greenfield | legacy | Rust | 9 | 0s | 110.3s | 11/11 PASS | 30/30 PASS | $0.56 |
| greenfield | legacy | Rust | 10 | 0s | 89.2s | 11/11 PASS | 30/30 PASS | $0.45 |
| greenfield | legacy | Rust | 11 | 0s | 93.6s | 11/11 PASS | 30/30 PASS | $0.48 |
| greenfield | legacy | Rust | 12 | 0s | 95.2s | 11/11 PASS | 30/30 PASS | $0.49 |
| greenfield | legacy | Rust | 13 | 0s | 81.8s | 11/11 PASS | 30/30 PASS | $0.44 |
| greenfield | legacy | Rust | 14 | 0s | 86.2s | 11/11 PASS | 30/30 PASS | $0.42 |
| greenfield | legacy | Rust | 15 | 0s | 95.3s | 11/11 PASS | 30/30 PASS | $0.48 |
| greenfield | legacy | Rust | 16 | 0s | 126.3s | 11/11 PASS | 30/30 PASS | $0.59 |
| greenfield | legacy | Rust | 17 | 0s | 89.0s | 11/11 PASS | 30/30 PASS | $0.44 |
| greenfield | legacy | Rust | 18 | 0s | 92.8s | 11/11 PASS | 30/30 PASS | $0.42 |
| greenfield | legacy | Rust | 19 | 0s | 89.5s | 11/11 PASS | 30/30 PASS | $0.49 |
| greenfield | legacy | Rust | 20 | 0s | 102.8s | 11/11 PASS | 30/30 PASS | $0.51 |
| greenfield | legacy | Scheme | 1 | 0s | 278.7s | 11/11 PASS | 30/30 PASS | $1.08 |
| greenfield | legacy | Scheme | 2 | 0s | 148.2s | 11/11 PASS | 30/30 PASS | $0.69 |
| greenfield | legacy | Scheme | 3 | 0s | 171.9s | 11/11 PASS | 30/30 PASS | $0.78 |
| greenfield | legacy | Scheme | 4 | 0s | 97.0s | 11/11 PASS | 30/30 PASS | $0.46 |
| greenfield | legacy | Scheme | 5 | 0s | 111.9s | 11/11 PASS | 30/30 PASS | $0.52 |
| greenfield | legacy | Scheme | 6 | 0s | 112.2s | 11/11 PASS | 30/30 PASS | $0.51 |
| greenfield | legacy | Scheme | 7 | 0s | 102.5s | 11/11 PASS | 30/30 PASS | $0.50 |
| greenfield | legacy | Scheme | 8 | 0s | 102.6s | 11/11 PASS | 30/30 PASS | $0.48 |
| greenfield | legacy | Scheme | 9 | 0s | 124.9s | 11/11 PASS | 30/30 PASS | $0.58 |
| greenfield | legacy | Scheme | 10 | 0s | 107.8s | 11/11 PASS | 30/30 PASS | $0.52 |
| greenfield | legacy | Scheme | 11 | 0s | 119.8s | 11/11 PASS | 30/30 PASS | $0.53 |
| greenfield | legacy | Scheme | 12 | 0s | 113.2s | 11/11 PASS | 30/30 PASS | $0.56 |
| greenfield | legacy | Scheme | 13 | 0s | 148.0s | 11/11 PASS | 30/30 PASS | $0.69 |
| greenfield | legacy | Scheme | 14 | 0s | 112.2s | 11/11 PASS | 30/30 PASS | $0.55 |
| greenfield | legacy | Scheme | 15 | 0s | 111.7s | 11/11 PASS | 30/30 PASS | $0.52 |
| greenfield | legacy | Scheme | 16 | 0s | 127.2s | 11/11 PASS | 30/30 PASS | $0.60 |
| greenfield | legacy | Scheme | 17 | 0s | 120.0s | 11/11 PASS | 30/30 PASS | $0.57 |
| greenfield | legacy | Scheme | 18 | 0s | 133.8s | 11/11 PASS | 30/30 PASS | $0.64 |
| greenfield | legacy | Scheme | 19 | 0s | 153.6s | 11/11 PASS | 30/30 PASS | $0.68 |
| greenfield | legacy | Scheme | 20 | 0s | 115.0s | 11/11 PASS | 30/30 PASS | $0.59 |
| greenfield | legacy | Typescript | 1 | 0s | 138.2s | 11/11 PASS | 30/30 PASS | $0.51 |
| greenfield | legacy | Typescript | 2 | 0s | 123.4s | 11/11 PASS | 30/30 PASS | $0.50 |
| greenfield | legacy | Typescript | 3 | 0s | 212.2s | 11/11 PASS | 30/30 PASS | $0.97 |
| greenfield | legacy | Typescript | 4 | 0s | 137.3s | 11/11 PASS | 30/30 PASS | $0.59 |
| greenfield | legacy | Typescript | 5 | 0s | 113.0s | 11/11 PASS | 30/30 PASS | $0.61 |
| greenfield | legacy | Typescript | 6 | 0s | 104.8s | 11/11 PASS | 30/30 PASS | $0.49 |
| greenfield | legacy | Typescript | 7 | 0s | 126.2s | 11/11 PASS | 30/30 PASS | $0.50 |
| greenfield | legacy | Typescript | 8 | 0s | 113.4s | 11/11 PASS | 30/30 PASS | $0.53 |
| greenfield | legacy | Typescript | 9 | 0s | 115.6s | 11/11 PASS | 30/30 PASS | $0.49 |
| greenfield | legacy | Typescript | 10 | 0s | 211.0s | 11/11 PASS | 30/30 PASS | $1.06 |
| greenfield | legacy | Typescript | 11 | 0s | 131.8s | 11/11 PASS | 30/30 PASS | $0.68 |
| greenfield | legacy | Typescript | 12 | 0s | 119.8s | 11/11 PASS | 30/30 PASS | $0.53 |
| greenfield | legacy | Typescript | 13 | 0s | 158.1s | 11/11 PASS | 30/30 PASS | $0.79 |
| greenfield | legacy | Typescript | 14 | 0s | 123.1s | 11/11 PASS | 30/30 PASS | $0.63 |
| greenfield | legacy | Typescript | 15 | 0s | 129.6s | 11/11 PASS | 30/30 PASS | $0.51 |
| greenfield | legacy | Typescript | 16 | 0s | 110.8s | 11/11 PASS | 30/30 PASS | $0.46 |
| greenfield | legacy | Typescript | 17 | 0s | 115.9s | 11/11 PASS | 30/30 PASS | $0.57 |
| greenfield | legacy | Typescript | 18 | 0s | 132.7s | 11/11 PASS | 30/30 PASS | $0.69 |
| greenfield | legacy | Typescript | 19 | 0s | 121.0s | 11/11 PASS | 30/30 PASS | $0.63 |
| greenfield | legacy | Typescript | 20 | 0s | 121.5s | 11/11 PASS | 30/30 PASS | $0.63 |

## Full Tokens
| Track | Subject | Trial | Phase | Input | Output | Cache Create | Cache Read | Total | Cost USD |
|-------|---------|-------|-------|-------|--------|--------------|------------|-------|----------|
| canonical | Go / go | 1 | v1 | 14 | 3,106 | 33,908 | 211,278 | 248,306 | $0.0000 |
| canonical | Go / go | 1 | v2 | 15 | 4,040 | 44,345 | 295,032 | 343,432 | $0.0000 |
| canonical | Go / go | 2 | v1 | 11 | 3,380 | 36,038 | 191,168 | 230,597 | $0.0000 |
| canonical | Go / go | 2 | v2 | 16 | 5,649 | 46,289 | 336,090 | 388,044 | $0.0000 |
| canonical | Go / go | 3 | v1 | 11 | 2,711 | 34,894 | 187,074 | 224,690 | $0.0000 |
| canonical | Go / go | 3 | v2 | 18 | 3,755 | 46,749 | 441,064 | 491,586 | $0.0000 |
| canonical | Java / Maven | 1 | v1 | 16 | 6,679 | 40,887 | 305,825 | 353,407 | $0.0000 |
| canonical | Java / Maven | 1 | v2 | 15 | 3,215 | 43,675 | 292,663 | 339,568 | $0.0000 |
| canonical | Java / Maven | 2 | v1 | 15 | 6,731 | 40,432 | 346,827 | 394,005 | $0.0000 |
| canonical | Java / Maven | 2 | v2 | 17 | 3,589 | 43,660 | 368,776 | 416,042 | $0.0000 |
| canonical | Java / Maven | 3 | v1 | 22 | 5,177 | 40,136 | 446,187 | 491,522 | $0.0000 |
| canonical | Java / Maven | 3 | v2 | 15 | 6,839 | 49,347 | 314,100 | 370,301 | $0.0000 |
| canonical | Kotlin / Gradle | 1 | v1 | 22 | 4,162 | 40,720 | 541,661 | 586,565 | $0.0000 |
| canonical | Kotlin / Gradle | 1 | v2 | 15 | 3,079 | 47,239 | 316,778 | 367,111 | $0.0000 |
| canonical | Kotlin / Gradle | 2 | v1 | 18 | 5,068 | 39,614 | 373,065 | 417,765 | $0.0000 |
| canonical | Kotlin / Gradle | 2 | v2 | 18 | 5,285 | 44,518 | 323,786 | 373,607 | $0.0000 |
| canonical | Kotlin / Gradle | 3 | v1 | 19 | 3,942 | 38,720 | 337,971 | 380,652 | $0.0000 |
| canonical | Kotlin / Gradle | 3 | v2 | 5,746 | 6,883 | 55,295 | 410,650 | 478,574 | $0.0000 |
| canonical | Python / uv | 1 | v1 | 16 | 4,041 | 39,593 | 300,245 | 343,895 | $0.0000 |
| canonical | Python / uv | 1 | v2 | 15 | 3,920 | 46,239 | 301,579 | 351,753 | $0.0000 |
| canonical | Ruby / Bundler | 1 | v1 | 14 | 3,992 | 37,761 | 226,782 | 268,549 | $0.0000 |
| canonical | Ruby / Bundler | 1 | v2 | 14 | 4,713 | 47,311 | 259,789 | 311,827 | $0.0000 |
| canonical | Ruby / Bundler | 2 | v1 | 15 | 3,787 | 37,881 | 261,267 | 302,950 | $0.0000 |
| canonical | Ruby / Bundler | 2 | v2 | 15 | 3,409 | 41,876 | 260,208 | 305,508 | $0.0000 |
| canonical | Ruby / Bundler | 3 | v1 | 15 | 3,436 | 37,175 | 259,342 | 299,968 | $0.0000 |
| canonical | Ruby / Bundler | 3 | v2 | 14 | 3,875 | 43,604 | 250,517 | 298,010 | $0.0000 |
| canonical | Rust / Cargo | 1 | v1 | 183 | 3,033 | 36,620 | 217,916 | 257,752 | $0.0000 |
| canonical | Rust / Cargo | 1 | v2 | 17 | 4,026 | 46,826 | 378,366 | 429,235 | $0.0000 |
| canonical | Scala / sbt | 1 | v1 | 1,432 | 7,715 | 46,055 | 374,387 | 429,589 | $0.0000 |
| canonical | Scala / sbt | 1 | v2 | 5,747 | 4,227 | 49,202 | 314,526 | 373,702 | $0.0000 |
| canonical | Scala / sbt | 2 | v1 | 16 | 6,963 | 45,207 | 419,126 | 471,312 | $0.0000 |
| canonical | Scala / sbt | 2 | v2 | 14 | 4,624 | 52,095 | 284,028 | 340,761 | $0.0000 |
| canonical | Scala / sbt | 3 | v1 | 19 | 10,836 | 48,972 | 467,985 | 527,812 | $0.0000 |
| canonical | Scala / sbt | 3 | v2 | 16 | 5,580 | 53,697 | 506,227 | 565,520 | $0.0000 |
| canonical | C# / dotnet | 1 | v1 | 25 | 6,130 | 40,107 | 554,483 | 600,745 | $0.0000 |
| canonical | C# / dotnet | 1 | v2 | 17 | 6,132 | 55,225 | 440,371 | 501,745 | $0.0000 |
| canonical | C# / dotnet | 2 | v1 | 20 | 5,257 | 40,676 | 462,606 | 508,559 | $0.0000 |
| canonical | C# / dotnet | 2 | v2 | 15 | 4,584 | 50,556 | 322,306 | 377,461 | $0.0000 |
| canonical | C# / dotnet | 3 | v1 | 27 | 7,087 | 44,933 | 689,803 | 741,850 | $0.0000 |
| canonical | C# / dotnet | 3 | v2 | 17 | 7,068 | 53,563 | 437,683 | 498,331 | $0.0000 |
| canonical | Clojure / Leiningen | 1 | v1 | 15 | 5,818 | 39,712 | 256,043 | 301,588 | $0.0000 |
| canonical | Clojure / Leiningen | 1 | v2 | 15 | 4,606 | 49,441 | 319,604 | 373,666 | $0.0000 |
| canonical | Clojure / Leiningen | 2 | v1 | 1,436 | 9,562 | 47,040 | 558,537 | 616,575 | $0.0000 |
| canonical | Clojure / Leiningen | 2 | v2 | 17 | 5,017 | 46,955 | 382,358 | 434,347 | $0.0000 |
| canonical | Clojure / Leiningen | 3 | v1 | 1,433 | 7,842 | 42,946 | 384,528 | 436,749 | $0.0000 |
| canonical | Clojure / Leiningen | 3 | v2 | 14 | 4,687 | 49,278 | 275,538 | 329,517 | $0.0000 |
| canonical | Elixir / Mix | 1 | v1 | 16 | 7,060 | 40,807 | 237,569 | 285,452 | $0.0000 |
| canonical | Elixir / Mix | 1 | v2 | 14 | 4,010 | 47,888 | 266,525 | 318,437 | $0.0000 |
| canonical | Elixir / Mix | 2 | v1 | 16 | 7,487 | 41,185 | 310,023 | 358,711 | $0.0000 |
| canonical | Elixir / Mix | 2 | v2 | 14 | 4,326 | 45,182 | 255,628 | 305,150 | $0.0000 |
| canonical | Elixir / Mix | 3 | v1 | 14 | 3,376 | 37,098 | 224,420 | 264,908 | $0.0000 |
| canonical | Elixir / Mix | 3 | v2 | 15 | 4,588 | 46,173 | 298,249 | 349,025 | $0.0000 |
| canonical | F# / dotnet | 1 | v1 | 20 | 5,166 | 41,407 | 467,049 | 513,642 | $0.0000 |
| canonical | F# / dotnet | 1 | v2 | 15 | 5,248 | 50,909 | 326,932 | 383,104 | $0.0000 |
| canonical | F# / dotnet | 2 | v1 | 19 | 5,502 | 43,750 | 446,017 | 495,288 | $0.0000 |
| canonical | F# / dotnet | 2 | v2 | 19 | 6,641 | 52,751 | 529,854 | 589,265 | $0.0000 |
| canonical | F# / dotnet | 3 | v1 | 20 | 4,551 | 40,852 | 463,010 | 508,433 | $0.0000 |
| canonical | F# / dotnet | 3 | v2 | 19 | 5,140 | 54,214 | 551,082 | 610,455 | $0.0000 |
| canonical | Java / Gradle | 1 | v1 | 18 | 5,585 | 39,902 | 451,908 | 497,413 | $0.0000 |
| canonical | Java / Gradle | 1 | v2 | 16 | 4,687 | 40,109 | 309,851 | 354,663 | $0.0000 |
| canonical | Java / Gradle | 2 | v1 | 21 | 7,396 | 42,891 | 425,533 | 475,841 | $0.0000 |
| canonical | Java / Gradle | 2 | v2 | 14 | 8,625 | 51,370 | 273,310 | 333,319 | $0.0000 |
| canonical | Java / Gradle | 3 | v1 | 20 | 4,439 | 39,963 | 372,649 | 417,071 | $0.0000 |
| canonical | Java / Gradle | 3 | v2 | 19 | 3,654 | 44,898 | 381,010 | 429,581 | $0.0000 |
| canonical | JavaScript / Node | 1 | v1 | 10 | 4,175 | 36,569 | 151,440 | 192,194 | $0.0000 |
| canonical | JavaScript / Node | 1 | v2 | 13 | 3,302 | 42,627 | 204,556 | 250,498 | $0.0000 |
| canonical | JavaScript / Node | 2 | v1 | 10 | 2,316 | 34,903 | 149,771 | 187,000 | $0.0000 |
| canonical | JavaScript / Node | 2 | v2 | 13 | 3,820 | 42,737 | 203,835 | 250,405 | $0.0000 |
| canonical | JavaScript / Node | 3 | v1 | 10 | 4,957 | 37,937 | 154,670 | 197,574 | $0.0000 |
| canonical | JavaScript / Node | 3 | v2 | 14 | 4,326 | 44,653 | 248,353 | 297,346 | $0.0000 |
| canonical | PHP / Composer | 1 | v1 | 15 | 17,085 | 51,977 | 285,344 | 354,421 | $0.0000 |
| canonical | PHP / Composer | 1 | v2 | 14 | 2,973 | 44,406 | 256,409 | 303,802 | $0.0000 |
| canonical | PHP / Composer | 2 | v1 | 13 | 18,969 | 53,499 | 287,039 | 359,520 | $0.0000 |
| canonical | PHP / Composer | 2 | v2 | 14 | 3,263 | 45,069 | 261,235 | 309,581 | $0.0000 |
| canonical | PHP / Composer | 3 | v1 | 17 | 19,039 | 53,885 | 383,643 | 456,584 | $0.0000 |
| canonical | PHP / Composer | 3 | v2 | 13 | 3,813 | 45,035 | 216,800 | 265,661 | $0.0000 |
| canonical | Python / pip | 1 | v1 | 17 | 3,532 | 42,674 | 353,303 | 399,526 | $0.0000 |
| canonical | Python / pip | 1 | v2 | 21 | 6,389 | 61,167 | 558,649 | 626,226 | $0.0000 |
| canonical | Python / pip | 2 | v1 | 19 | 3,621 | 44,814 | 373,098 | 421,552 | $0.0000 |
| canonical | Python / pip | 2 | v2 | 16 | 3,926 | 59,053 | 400,641 | 463,636 | $0.0000 |
| canonical | Python / pip | 3 | v1 | 13 | 3,204 | 43,792 | 288,768 | 335,777 | $0.0000 |
| canonical | Python / pip | 3 | v2 | 17 | 3,508 | 58,406 | 438,479 | 500,410 | $0.0000 |
| canonical | Scala / sbt (server) | 1 | v1 | 17 | 8,593 | 26,211 | 438,118 | 472,939 | $0.0000 |
| canonical | Scala / sbt (server) | 1 | v2 | 5,747 | 5,034 | 25,660 | 341,644 | 378,085 | $0.0000 |
| canonical | Scala / sbt (server) | 2 | v1 | 15 | 9,839 | 23,901 | 428,037 | 461,792 | $0.0000 |
| canonical | Scala / sbt (server) | 2 | v2 | 14 | 4,008 | 27,153 | 306,133 | 337,308 | $0.0000 |
| canonical | Scala / sbt (server) | 3 | v1 | 16 | 8,151 | 22,824 | 465,219 | 496,210 | $0.0000 |
| canonical | Scala / sbt (server) | 3 | v2 | 16 | 4,005 | 25,366 | 397,301 | 426,688 | $0.0000 |
| canonical | Scala 2.13 / sbt | 1 | v1 | 16 | 13,187 | 54,740 | 384,592 | 452,535 | $0.0000 |
| canonical | Scala 2.13 / sbt | 1 | v2 | 20 | 4,229 | 52,178 | 584,221 | 640,648 | $0.0000 |
| canonical | Scala 2.13 / sbt | 2 | v1 | 2,584 | 7,030 | 46,062 | 421,875 | 477,551 | $0.0000 |
| canonical | Scala 2.13 / sbt | 2 | v2 | 6,130 | 4,642 | 107,400 | 447,118 | 565,290 | $0.0000 |
| canonical | Scala 2.13 / sbt | 3 | v1 | 17 | 9,720 | 48,312 | 393,700 | 451,749 | $0.0000 |
| canonical | Scala 2.13 / sbt | 3 | v2 | 403 | 4,481 | 52,792 | 326,257 | 383,933 | $0.0000 |
| canonical | VB.NET / dotnet | 1 | v1 | 16 | 9,827 | 44,160 | 418,790 | 472,793 | $0.0000 |
| canonical | VB.NET / dotnet | 1 | v2 | 16 | 6,219 | 52,381 | 394,842 | 453,458 | $0.0000 |
| canonical | VB.NET / dotnet | 2 | v1 | 24 | 5,668 | 43,144 | 641,556 | 690,392 | $0.0000 |
| canonical | VB.NET / dotnet | 2 | v2 | 16 | 5,757 | 54,530 | 380,194 | 440,497 | $0.0000 |
| canonical | VB.NET / dotnet | 3 | v1 | 22 | 7,552 | 44,750 | 567,241 | 619,565 | $0.0000 |
| canonical | VB.NET / dotnet | 3 | v2 | 18 | 4,954 | 52,035 | 483,653 | 540,660 | $0.0000 |
| canonical | PowerShell / raw | 1 | v1 | 27 | 33,895 | 69,080 | 944,671 | 1,047,673 | $0.0000 |
| canonical | PowerShell / raw | 1 | v2 | 13 | 3,314 | 44,289 | 213,074 | 260,690 | $0.0000 |
| canonical | PowerShell / raw | 2 | v1 | 36 | 27,971 | 63,800 | 1,521,947 | 1,613,754 | $0.0000 |
| canonical | PowerShell / raw | 2 | v2 | 13 | 9,067 | 50,369 | 225,500 | 284,949 | $0.0000 |
| canonical | PowerShell / raw | 3 | v1 | 12 | 8,612 | 42,826 | 242,835 | 294,285 | $0.0000 |
| canonical | PowerShell / raw | 3 | v2 | 14 | 4,780 | 45,530 | 249,381 | 299,705 | $0.0000 |
| canonical | Prolog / SWI-Prolog | 1 | v1 | - | - | - | - | - | - |
| canonical | Prolog / SWI-Prolog | 1 | v2 | - | - | - | - | - | - |
| canonical | Prolog / SWI-Prolog | 1 | v1 | - | - | - | - | - | - |
| canonical | Prolog / SWI-Prolog | 1 | v2 | - | - | - | - | - | - |
| canonical | Prolog / SWI-Prolog | 1 | v1 | 15 | 23,452 | 51,195 | 332,552 | 407,214 | $0.0000 |
| canonical | Prolog / SWI-Prolog | 1 | v2 | 18 | 8,404 | 48,740 | 440,012 | 497,174 | $0.0000 |
| canonical | Prolog / SWI-Prolog | 2 | v1 | 19 | 30,358 | 63,541 | 432,752 | 526,670 | $0.0000 |
| canonical | Prolog / SWI-Prolog | 2 | v2 | 10 | 9,136 | 48,931 | 171,824 | 229,901 | $0.0000 |
| canonical | Prolog / SWI-Prolog | 3 | v1 | 13 | 20,597 | 53,230 | 219,578 | 293,418 | $0.0000 |
| canonical | Prolog / SWI-Prolog | 3 | v2 | 10 | 4,628 | 44,002 | 166,712 | 215,352 | $0.0000 |
| greenfield | C | 1 | v1 | 8 | 4,501 | 10,444 | 152,603 | 167,556 | $0.2541 |
| greenfield | C | 1 | v2 | 12 | 4,988 | 20,199 | 330,911 | 356,110 | $0.4165 |
| greenfield | C | 2 | v1 | 7 | 4,250 | 10,194 | 123,194 | 137,645 | $0.2316 |
| greenfield | C | 2 | v2 | 13 | 4,973 | 19,913 | 358,374 | 383,273 | $0.4280 |
| greenfield | C | 3 | v1 | 10 | 4,855 | 11,059 | 208,659 | 224,583 | $0.2949 |
| greenfield | C | 3 | v2 | 22 | 8,035 | 26,430 | 756,595 | 791,082 | $0.7445 |
| greenfield | C | 4 | v1 | 15 | 8,135 | 14,992 | 373,967 | 397,109 | $0.4841 |
| greenfield | C | 4 | v2 | 12 | 5,554 | 21,028 | 334,977 | 361,571 | $0.4378 |
| greenfield | C | 5 | v1 | 9 | 4,914 | 11,671 | 184,113 | 200,707 | $0.2879 |
| greenfield | C | 5 | v2 | 10 | 4,143 | 23,385 | 261,339 | 288,877 | $0.3805 |
| greenfield | C | 6 | v1 | 10 | 4,037 | 10,352 | 208,584 | 222,983 | $0.2700 |
| greenfield | C | 6 | v2 | 9 | 6,198 | 20,718 | 219,890 | 246,815 | $0.3944 |
| greenfield | C | 7 | v1 | 8 | 4,114 | 11,648 | 153,437 | 169,207 | $0.2524 |
| greenfield | C | 7 | v2 | 18 | 6,440 | 24,122 | 573,045 | 603,625 | $0.5984 |
| greenfield | C | 8 | v1 | 7 | 4,093 | 10,092 | 123,010 | 137,202 | $0.2269 |
| greenfield | C | 8 | v2 | 12 | 4,934 | 19,965 | 324,970 | 349,881 | $0.4107 |
| greenfield | C | 9 | v1 | 8 | 3,874 | 10,141 | 151,016 | 165,039 | $0.2358 |
| greenfield | C | 9 | v2 | 13 | 8,530 | 25,425 | 382,318 | 416,286 | $0.5634 |
| greenfield | C | 10 | v1 | 9 | 4,097 | 10,715 | 180,592 | 195,413 | $0.2597 |
| greenfield | C | 10 | v2 | 11 | 4,444 | 21,866 | 283,123 | 309,444 | $0.3894 |
| greenfield | C | 11 | v1 | 8 | 4,080 | 10,403 | 151,584 | 166,075 | $0.2429 |
| greenfield | C | 11 | v2 | 16 | 6,218 | 23,122 | 487,957 | 517,313 | $0.5440 |
| greenfield | C | 12 | v1 | 12 | 4,645 | 12,243 | 272,245 | 289,145 | $0.3288 |
| greenfield | C | 12 | v2 | 9 | 4,209 | 18,856 | 208,107 | 231,181 | $0.3272 |
| greenfield | C | 13 | v1 | 6 | 3,767 | 9,789 | 93,875 | 107,437 | $0.2023 |
| greenfield | C | 13 | v2 | 13 | 6,044 | 20,640 | 365,078 | 391,775 | $0.4627 |
| greenfield | C | 14 | v1 | 10 | 3,968 | 10,980 | 210,425 | 225,383 | $0.2731 |
| greenfield | C | 14 | v2 | 13 | 4,980 | 20,288 | 360,419 | 385,700 | $0.4316 |
| greenfield | C | 15 | v1 | 8 | 3,741 | 9,710 | 150,426 | 163,885 | $0.2295 |
| greenfield | C | 15 | v2 | 10 | 5,834 | 20,251 | 252,484 | 278,579 | $0.3987 |
| greenfield | C | 16 | v1 | 6 | 3,798 | 9,800 | 93,840 | 107,444 | $0.2032 |
| greenfield | C | 16 | v2 | 16 | 6,880 | 23,192 | 486,948 | 517,036 | $0.5605 |
| greenfield | C | 17 | v1 | 8 | 4,213 | 12,195 | 155,663 | 172,079 | $0.2594 |
| greenfield | C | 17 | v2 | 8 | 4,606 | 19,358 | 179,092 | 203,064 | $0.3257 |
| greenfield | C | 18 | v1 | 9 | 4,320 | 10,997 | 182,518 | 197,844 | $0.2680 |
| greenfield | C | 18 | v2 | 12 | 4,772 | 19,489 | 325,832 | 350,105 | $0.4041 |
| greenfield | C | 19 | v1 | 6 | 3,671 | 10,008 | 93,747 | 107,432 | $0.2012 |
| greenfield | C | 19 | v2 | 11 | 5,052 | 20,762 | 293,212 | 319,037 | $0.4027 |
| greenfield | C | 20 | v1 | 6 | 3,916 | 10,002 | 93,997 | 107,921 | $0.2074 |
| greenfield | C | 20 | v2 | 24 | 10,646 | 34,115 | 949,973 | 994,758 | $0.9545 |
| greenfield | Go | 1 | v1 | 19 | 11,337 | 19,594 | 527,744 | 558,694 | $0.6699 |
| greenfield | Go | 1 | v2 | 10 | 3,876 | 16,260 | 239,184 | 259,330 | $0.3182 |
| greenfield | Go | 2 | v1 | 7 | 2,319 | 8,317 | 119,430 | 130,073 | $0.1697 |
| greenfield | Go | 2 | v2 | 8 | 3,388 | 15,630 | 168,953 | 187,979 | $0.2669 |
| greenfield | Go | 3 | v1 | 10 | 3,693 | 9,856 | 203,065 | 216,624 | $0.2555 |
| greenfield | Go | 3 | v2 | 11 | 3,939 | 16,458 | 268,525 | 288,933 | $0.3357 |
| greenfield | Go | 4 | v1 | 8 | 2,353 | 8,389 | 146,047 | 156,797 | $0.1843 |
| greenfield | Go | 4 | v2 | 12 | 4,124 | 16,493 | 306,203 | 326,832 | $0.3593 |
| greenfield | Go | 5 | v1 | 8 | 2,192 | 8,198 | 145,918 | 156,316 | $0.1790 |
| greenfield | Go | 5 | v2 | 10 | 3,941 | 16,182 | 238,373 | 258,506 | $0.3189 |
| greenfield | Go | 6 | v1 | 7 | 2,256 | 8,262 | 119,328 | 129,853 | $0.1677 |
| greenfield | Go | 6 | v2 | 10 | 3,074 | 15,406 | 234,495 | 252,985 | $0.2904 |
| greenfield | Go | 7 | v1 | 7 | 2,204 | 8,215 | 119,260 | 129,686 | $0.1661 |
| greenfield | Go | 7 | v2 | 9 | 2,911 | 15,191 | 200,097 | 218,208 | $0.2678 |
| greenfield | Go | 8 | v1 | 8 | 2,215 | 8,189 | 145,900 | 156,312 | $0.1795 |
| greenfield | Go | 8 | v2 | 7 | 3,166 | 15,358 | 129,014 | 147,545 | $0.2397 |
| greenfield | Go | 9 | v1 | 7 | 2,161 | 8,176 | 119,170 | 129,514 | $0.1647 |
| greenfield | Go | 9 | v2 | 10 | 3,925 | 16,146 | 238,159 | 258,240 | $0.3182 |
| greenfield | Go | 10 | v1 | 8 | 2,278 | 8,256 | 146,025 | 156,567 | $0.1816 |
| greenfield | Go | 10 | v2 | 10 | 3,277 | 15,623 | 229,711 | 248,621 | $0.2945 |
| greenfield | Go | 11 | v1 | 8 | 2,257 | 8,233 | 146,074 | 156,572 | $0.1810 |
| greenfield | Go | 11 | v2 | 10 | 3,059 | 15,394 | 234,462 | 252,925 | $0.2900 |
| greenfield | Go | 12 | v1 | 7 | 2,276 | 8,294 | 119,423 | 130,000 | $0.1685 |
| greenfield | Go | 12 | v2 | 8 | 2,818 | 15,291 | 161,064 | 179,181 | $0.2466 |
| greenfield | Go | 13 | v1 | 8 | 2,258 | 8,226 | 146,061 | 156,553 | $0.1809 |
| greenfield | Go | 13 | v2 | 10 | 3,180 | 15,979 | 234,685 | 253,854 | $0.2968 |
| greenfield | Go | 14 | v1 | 8 | 2,234 | 8,219 | 146,038 | 156,499 | $0.1803 |
| greenfield | Go | 14 | v2 | 10 | 3,484 | 15,774 | 235,507 | 254,775 | $0.3035 |
| greenfield | Go | 15 | v1 | 7 | 2,312 | 8,310 | 119,460 | 130,089 | $0.1695 |
| greenfield | Go | 15 | v2 | 10 | 3,044 | 15,453 | 234,747 | 253,254 | $0.2901 |
| greenfield | Go | 16 | v1 | 7 | 2,221 | 8,242 | 119,318 | 129,788 | $0.1667 |
| greenfield | Go | 16 | v2 | 10 | 3,070 | 15,383 | 234,384 | 252,847 | $0.2901 |
| greenfield | Go | 17 | v1 | 7 | 2,376 | 8,385 | 119,603 | 130,371 | $0.1716 |
| greenfield | Go | 17 | v2 | 12 | 3,186 | 10,444 | 258,476 | 272,118 | $0.2742 |
| greenfield | Go | 18 | v1 | 8 | 2,237 | 8,206 | 146,008 | 156,459 | $0.1803 |
| greenfield | Go | 18 | v2 | 10 | 3,704 | 16,216 | 223,266 | 243,196 | $0.3056 |
| greenfield | Go | 19 | v1 | 7 | 2,268 | 8,271 | 119,329 | 129,875 | $0.1681 |
| greenfield | Go | 19 | v2 | 8 | 2,824 | 15,206 | 160,846 | 178,884 | $0.2461 |
| greenfield | Go | 20 | v1 | 7 | 2,423 | 8,427 | 119,680 | 130,537 | $0.1731 |
| greenfield | Go | 20 | v2 | 10 | 3,647 | 16,272 | 231,982 | 251,911 | $0.3089 |
| greenfield | Haskell | 1 | v1 | 13 | 2,866 | 9,114 | 281,106 | 293,099 | $0.2692 |
| greenfield | Haskell | 1 | v2 | 22 | 9,365 | 26,769 | 722,526 | 758,682 | $0.7628 |
| greenfield | Haskell | 2 | v1 | 12 | 4,760 | 11,088 | 261,897 | 277,757 | $0.3193 |
| greenfield | Haskell | 2 | v2 | 12 | 3,510 | 15,626 | 294,286 | 313,434 | $0.3326 |
| greenfield | Haskell | 3 | v1 | 13 | 13,081 | 20,401 | 363,172 | 396,667 | $0.6362 |
| greenfield | Haskell | 3 | v2 | 13 | 3,732 | 15,973 | 335,958 | 355,676 | $0.3612 |
| greenfield | Haskell | 4 | v1 | 10 | 4,069 | 10,657 | 208,512 | 223,248 | $0.2726 |
| greenfield | Haskell | 4 | v2 | 16 | 4,486 | 20,867 | 453,569 | 478,938 | $0.4694 |
| greenfield | Haskell | 5 | v1 | 9 | 2,285 | 8,649 | 174,509 | 185,452 | $0.1985 |
| greenfield | Haskell | 5 | v2 | 12 | 3,455 | 16,258 | 295,720 | 315,445 | $0.3359 |
| greenfield | Haskell | 6 | v1 | 9 | 3,597 | 9,773 | 176,851 | 190,230 | $0.2395 |
| greenfield | Haskell | 6 | v2 | 24 | 5,394 | 22,318 | 768,694 | 796,430 | $0.6588 |
| greenfield | Haskell | 7 | v1 | 17 | 3,770 | 10,920 | 404,772 | 419,479 | $0.3650 |
| greenfield | Haskell | 7 | v2 | 19 | 5,032 | 21,622 | 550,203 | 576,876 | $0.5361 |
| greenfield | Haskell | 8 | v1 | 10 | 4,167 | 10,408 | 204,983 | 219,568 | $0.2718 |
| greenfield | Haskell | 8 | v2 | 10 | 2,668 | 15,220 | 221,565 | 239,463 | $0.2727 |
| greenfield | Haskell | 9 | v1 | 9 | 3,640 | 9,778 | 176,851 | 190,278 | $0.2406 |
| greenfield | Haskell | 9 | v2 | 22 | 6,749 | 20,047 | 679,600 | 706,418 | $0.6339 |
| greenfield | Haskell | 10 | v1 | 12 | 4,097 | 10,539 | 261,770 | 276,418 | $0.2992 |
| greenfield | Haskell | 10 | v2 | 23 | 5,559 | 20,563 | 715,648 | 741,793 | $0.6254 |
| greenfield | Haskell | 11 | v1 | 7 | 2,148 | 8,189 | 119,117 | 129,461 | $0.1645 |
| greenfield | Haskell | 11 | v2 | 23 | 6,213 | 23,636 | 736,229 | 766,101 | $0.6713 |
| greenfield | Haskell | 12 | v1 | 11 | 3,560 | 9,798 | 229,324 | 242,693 | $0.2650 |
| greenfield | Haskell | 12 | v2 | 17 | 5,746 | 18,625 | 485,141 | 509,529 | $0.5027 |
| greenfield | Haskell | 13 | v1 | 9 | 2,803 | 8,962 | 174,437 | 186,211 | $0.2134 |
| greenfield | Haskell | 13 | v2 | 11 | 3,244 | 15,852 | 260,402 | 279,509 | $0.3104 |
| greenfield | Haskell | 14 | v1 | 9 | 3,683 | 9,814 | 177,139 | 190,645 | $0.2420 |
| greenfield | Haskell | 14 | v2 | 18 | 4,696 | 17,916 | 510,806 | 533,436 | $0.4849 |
| greenfield | Haskell | 15 | v1 | 11 | 2,630 | 9,194 | 229,804 | 241,639 | $0.2382 |
| greenfield | Haskell | 15 | v2 | 22 | 6,771 | 22,885 | 713,346 | 743,024 | $0.6691 |
| greenfield | Haskell | 16 | v1 | 12 | 2,599 | 9,322 | 255,938 | 267,871 | $0.2513 |
| greenfield | Haskell | 16 | v2 | 11 | 4,981 | 17,954 | 272,832 | 295,778 | $0.3732 |
| greenfield | Haskell | 17 | v1 | 10 | 3,596 | 10,298 | 203,881 | 217,785 | $0.2563 |
| greenfield | Haskell | 17 | v2 | 12 | 3,462 | 16,060 | 294,583 | 314,117 | $0.3343 |
| greenfield | Haskell | 18 | v1 | 8 | 4,243 | 10,403 | 150,587 | 165,241 | $0.2464 |
| greenfield | Haskell | 18 | v2 | 11 | 2,948 | 15,739 | 261,022 | 279,720 | $0.3026 |
| greenfield | Haskell | 19 | v1 | 11 | 2,790 | 9,521 | 231,331 | 243,653 | $0.2450 |
| greenfield | Haskell | 19 | v2 | 13 | 4,909 | 18,161 | 346,216 | 369,299 | $0.4094 |
| greenfield | Haskell | 20 | v1 | 9 | 2,226 | 8,816 | 174,008 | 185,059 | $0.1978 |
| greenfield | Haskell | 20 | v2 | 11 | 3,189 | 15,968 | 261,536 | 280,704 | $0.3103 |
| greenfield | Java | 1 | v1 | 13 | 3,795 | 10,043 | 288,104 | 301,955 | $0.3018 |
| greenfield | Java | 1 | v2 | 5,661 | 3,042 | 16,507 | 200,959 | 226,169 | $0.3408 |
| greenfield | Java | 2 | v1 | 7 | 7,411 | 13,491 | 129,572 | 150,481 | $0.3344 |
| greenfield | Java | 2 | v2 | 13 | 3,968 | 17,140 | 341,072 | 362,193 | $0.3769 |
| greenfield | Java | 3 | v1 | 9 | 3,364 | 9,500 | 176,812 | 189,685 | $0.2319 |
| greenfield | Java | 3 | v2 | 10 | 3,204 | 16,485 | 237,839 | 257,538 | $0.3021 |
| greenfield | Java | 4 | v1 | 14 | 4,262 | 10,546 | 320,263 | 335,085 | $0.3327 |
| greenfield | Java | 4 | v2 | 8 | 2,949 | 15,935 | 162,742 | 181,634 | $0.2547 |
| greenfield | Java | 5 | v1 | 9 | 2,900 | 9,090 | 174,860 | 186,859 | $0.2168 |
| greenfield | Java | 5 | v2 | 8 | 2,780 | 15,038 | 160,358 | 178,184 | $0.2437 |
| greenfield | Java | 6 | v1 | 9 | 3,236 | 9,393 | 176,489 | 189,127 | $0.2279 |
| greenfield | Java | 6 | v2 | 8 | 3,143 | 15,872 | 162,542 | 181,565 | $0.2591 |
| greenfield | Java | 7 | v1 | 9 | 2,829 | 8,982 | 174,844 | 186,664 | $0.2143 |
| greenfield | Java | 7 | v2 | 8 | 2,556 | 14,770 | 160,025 | 177,359 | $0.2363 |
| greenfield | Java | 8 | v1 | 9 | 3,204 | 9,326 | 175,880 | 188,419 | $0.2264 |
| greenfield | Java | 8 | v2 | 8 | 2,632 | 15,256 | 161,316 | 179,212 | $0.2418 |
| greenfield | Java | 9 | v1 | 12 | 3,457 | 9,744 | 261,058 | 274,271 | $0.2779 |
| greenfield | Java | 9 | v2 | 8 | 2,590 | 15,054 | 160,832 | 178,484 | $0.2393 |
| greenfield | Java | 10 | v1 | 7 | 2,372 | 8,466 | 119,725 | 130,570 | $0.1721 |
| greenfield | Java | 10 | v2 | 12 | 3,446 | 16,599 | 302,758 | 322,815 | $0.3413 |
| greenfield | Java | 11 | v1 | 8 | 2,642 | 8,709 | 147,313 | 158,672 | $0.1942 |
| greenfield | Java | 11 | v2 | 9 | 4,403 | 17,015 | 204,412 | 225,839 | $0.3187 |
| greenfield | Java | 12 | v1 | 9 | 2,831 | 9,054 | 175,039 | 186,933 | $0.2149 |
| greenfield | Java | 12 | v2 | 8 | 2,627 | 15,061 | 160,800 | 178,496 | $0.2402 |
| greenfield | Java | 13 | v1 | 10 | 3,016 | 9,486 | 200,976 | 213,488 | $0.2352 |
| greenfield | Java | 13 | v2 | 10 | 3,203 | 15,710 | 233,724 | 252,647 | $0.2952 |
| greenfield | Java | 14 | v1 | 8 | 3,065 | 9,249 | 148,413 | 160,735 | $0.2087 |
| greenfield | Java | 14 | v2 | 8 | 2,671 | 15,145 | 160,980 | 178,804 | $0.2420 |
| greenfield | Java | 15 | v1 | 9 | 3,004 | 9,211 | 175,471 | 187,695 | $0.2204 |
| greenfield | Java | 15 | v2 | 8 | 2,648 | 14,922 | 160,296 | 177,874 | $0.2397 |
| greenfield | Java | 16 | v1 | 10 | 3,091 | 9,458 | 203,533 | 216,092 | $0.2382 |
| greenfield | Java | 16 | v2 | 8 | 4,309 | 16,767 | 168,330 | 189,414 | $0.2967 |
| greenfield | Java | 17 | v1 | 7 | 2,616 | 8,625 | 120,108 | 131,356 | $0.1794 |
| greenfield | Java | 17 | v2 | 9 | 2,835 | 15,824 | 197,457 | 216,125 | $0.2685 |
| greenfield | Java | 18 | v1 | 9 | 2,327 | 8,403 | 171,711 | 182,450 | $0.1966 |
| greenfield | Java | 18 | v2 | 8 | 2,791 | 15,123 | 160,500 | 178,422 | $0.2446 |
| greenfield | Java | 19 | v1 | 7 | 2,347 | 8,439 | 119,680 | 130,473 | $0.1713 |
| greenfield | Java | 19 | v2 | 8 | 2,604 | 14,981 | 160,557 | 178,150 | $0.2390 |
| greenfield | Java | 20 | v1 | 9 | 2,793 | 8,964 | 174,805 | 186,571 | $0.2133 |
| greenfield | Java | 20 | v2 | 8 | 2,542 | 14,792 | 160,121 | 177,463 | $0.2361 |
| greenfield | Javascript | 1 | v1 | 7 | 2,129 | 8,066 | 118,934 | 129,136 | $0.1631 |
| greenfield | Javascript | 1 | v2 | 8 | 3,453 | 15,716 | 168,629 | 187,806 | $0.2689 |
| greenfield | Javascript | 2 | v1 | 7 | 2,112 | 8,059 | 118,942 | 129,120 | $0.1627 |
| greenfield | Javascript | 2 | v2 | 8 | 3,663 | 16,012 | 169,336 | 189,019 | $0.2764 |
| greenfield | Javascript | 3 | v1 | 7 | 2,115 | 8,062 | 118,926 | 129,110 | $0.1628 |
| greenfield | Javascript | 3 | v2 | 7 | 2,583 | 14,763 | 134,230 | 151,583 | $0.2240 |
| greenfield | Javascript | 4 | v1 | 7 | 2,006 | 7,916 | 118,614 | 128,543 | $0.1590 |
| greenfield | Javascript | 4 | v2 | 7 | 2,556 | 14,614 | 134,000 | 151,177 | $0.2223 |
| greenfield | Javascript | 5 | v1 | 2,493 | 1,993 | 7,941 | 116,194 | 128,621 | $0.1700 |
| greenfield | Javascript | 5 | v2 | 8 | 2,517 | 14,550 | 153,431 | 170,506 | $0.2306 |
| greenfield | Javascript | 6 | v1 | 7 | 2,001 | 7,923 | 118,642 | 128,573 | $0.1589 |
| greenfield | Javascript | 6 | v2 | 9 | 2,667 | 14,771 | 186,444 | 203,891 | $0.2523 |
| greenfield | Javascript | 7 | v1 | 7 | 2,007 | 7,933 | 118,655 | 128,602 | $0.1591 |
| greenfield | Javascript | 7 | v2 | 7 | 2,417 | 14,396 | 127,852 | 144,672 | $0.2144 |
| greenfield | Javascript | 8 | v1 | 7 | 1,975 | 7,898 | 118,603 | 128,483 | $0.1581 |
| greenfield | Javascript | 8 | v2 | 7 | 3,070 | 15,132 | 134,514 | 152,723 | $0.2386 |
| greenfield | Javascript | 9 | v1 | 7 | 1,974 | 7,918 | 118,645 | 128,544 | $0.1582 |
| greenfield | Javascript | 9 | v2 | 8 | 2,399 | 14,484 | 153,349 | 170,240 | $0.2272 |
| greenfield | Javascript | 10 | v1 | 7 | 1,994 | 7,916 | 118,631 | 128,548 | $0.1587 |
| greenfield | Javascript | 10 | v2 | 8 | 2,618 | 14,898 | 163,802 | 181,326 | $0.2405 |
| greenfield | Javascript | 11 | v1 | 7 | 1,976 | 7,899 | 118,601 | 128,483 | $0.1581 |
| greenfield | Javascript | 11 | v2 | 7 | 2,894 | 9,336 | 117,286 | 129,523 | $0.1894 |
| greenfield | Javascript | 12 | v1 | 7 | 2,027 | 7,957 | 118,719 | 128,710 | $0.1598 |
| greenfield | Javascript | 12 | v2 | 7 | 2,649 | 14,796 | 134,255 | 151,707 | $0.2259 |
| greenfield | Javascript | 13 | v1 | 7 | 1,992 | 7,917 | 118,645 | 128,561 | $0.1586 |
| greenfield | Javascript | 13 | v2 | 8 | 2,596 | 14,883 | 163,805 | 181,292 | $0.2399 |
| greenfield | Javascript | 14 | v1 | 7 | 1,960 | 7,885 | 118,579 | 128,431 | $0.1576 |
| greenfield | Javascript | 14 | v2 | 8 | 2,445 | 14,685 | 163,553 | 180,691 | $0.2347 |
| greenfield | Javascript | 15 | v1 | 7 | 2,075 | 7,980 | 118,773 | 128,835 | $0.1612 |
| greenfield | Javascript | 15 | v2 | 7 | 2,685 | 11,115 | 122,858 | 136,665 | $0.1981 |
| greenfield | Javascript | 16 | v1 | 7 | 1,912 | 7,837 | 118,477 | 128,233 | $0.1561 |
| greenfield | Javascript | 16 | v2 | 7 | 2,369 | 14,273 | 127,654 | 144,303 | $0.2123 |
| greenfield | Javascript | 17 | v1 | 7 | 1,973 | 7,915 | 118,622 | 128,517 | $0.1581 |
| greenfield | Javascript | 17 | v2 | 8 | 2,939 | 9,535 | 144,818 | 157,300 | $0.2055 |
| greenfield | Javascript | 18 | v1 | 7 | 1,944 | 7,862 | 118,526 | 128,339 | $0.1570 |
| greenfield | Javascript | 18 | v2 | 7 | 2,349 | 14,359 | 133,666 | 150,381 | $0.2153 |
| greenfield | Javascript | 19 | v1 | 7 | 1,995 | 7,923 | 118,653 | 128,578 | $0.1588 |
| greenfield | Javascript | 19 | v2 | 8 | 2,474 | 14,561 | 153,465 | 170,508 | $0.2296 |
| greenfield | Javascript | 20 | v1 | 7 | 1,932 | 7,854 | 118,514 | 128,307 | $0.1567 |
| greenfield | Javascript | 20 | v2 | 7 | 2,407 | 14,426 | 133,738 | 150,578 | $0.2172 |
| greenfield | Lua | 1 | v1 | 8 | 3,107 | 9,047 | 146,252 | 158,414 | $0.2074 |
| greenfield | Lua | 1 | v2 | 8 | 3,525 | 16,833 | 172,070 | 192,436 | $0.2794 |
| greenfield | Lua | 2 | v1 | 9 | 3,180 | 9,283 | 173,811 | 186,283 | $0.2245 |
| greenfield | Lua | 2 | v2 | 11 | 3,723 | 16,840 | 274,876 | 295,450 | $0.3358 |
| greenfield | Lua | 3 | v1 | 8 | 12,488 | 18,367 | 174,556 | 205,419 | $0.5143 |
| greenfield | Lua | 3 | v2 | 8 | 2,646 | 15,223 | 168,009 | 185,886 | $0.2453 |
| greenfield | Lua | 4 | v1 | 10 | 6,085 | 16,537 | 220,403 | 243,035 | $0.3657 |
| greenfield | Lua | 4 | v2 | 8 | 2,823 | 15,693 | 156,273 | 174,797 | $0.2468 |
| greenfield | Lua | 5 | v1 | 12 | 5,549 | 14,898 | 270,693 | 291,152 | $0.3672 |
| greenfield | Lua | 5 | v2 | 11 | 3,927 | 11,199 | 234,574 | 249,711 | $0.2855 |
| greenfield | Lua | 6 | v1 | 14 | 7,482 | 14,082 | 346,053 | 367,631 | $0.4482 |
| greenfield | Lua | 6 | v2 | 7 | 3,200 | 18,814 | 141,730 | 163,751 | $0.2685 |
| greenfield | Lua | 7 | v1 | 12 | 4,857 | 11,375 | 265,780 | 282,024 | $0.3255 |
| greenfield | Lua | 7 | v2 | 8 | 2,758 | 15,913 | 157,083 | 175,762 | $0.2470 |
| greenfield | Lua | 8 | v1 | 10 | 4,184 | 10,487 | 208,893 | 223,574 | $0.2746 |
| greenfield | Lua | 8 | v2 | 7 | 2,714 | 16,892 | 138,380 | 157,993 | $0.2426 |
| greenfield | Lua | 9 | v1 | 7 | 2,887 | 8,862 | 120,415 | 132,171 | $0.1878 |
| greenfield | Lua | 9 | v2 | 6 | 2,783 | 16,014 | 107,119 | 125,922 | $0.2233 |
| greenfield | Lua | 10 | v1 | 11 | 4,125 | 10,427 | 236,434 | 250,997 | $0.2866 |
| greenfield | Lua | 10 | v2 | 10 | 2,667 | 17,016 | 228,752 | 248,445 | $0.2875 |
| greenfield | Lua | 11 | v1 | 10 | 4,518 | 11,323 | 209,162 | 225,013 | $0.2883 |
| greenfield | Lua | 11 | v2 | 7 | 2,719 | 10,415 | 123,974 | 137,115 | $0.1951 |
| greenfield | Lua | 12 | v1 | 13 | 6,232 | 16,596 | 305,176 | 328,017 | $0.4122 |
| greenfield | Lua | 12 | v2 | 8 | 3,437 | 16,274 | 170,355 | 190,074 | $0.2729 |
| greenfield | Lua | 13 | v1 | 12 | 5,142 | 14,931 | 276,326 | 296,411 | $0.3601 |
| greenfield | Lua | 13 | v2 | 8 | 2,615 | 12,707 | 157,649 | 172,979 | $0.2237 |
| greenfield | Lua | 14 | v1 | 12 | 5,211 | 11,730 | 268,643 | 285,596 | $0.3380 |
| greenfield | Lua | 14 | v2 | 8 | 2,990 | 16,155 | 165,942 | 185,095 | $0.2587 |
| greenfield | Lua | 15 | v1 | 14 | 4,321 | 10,697 | 318,687 | 333,719 | $0.3343 |
| greenfield | Lua | 15 | v2 | 9 | 2,697 | 18,068 | 208,905 | 229,679 | $0.2848 |
| greenfield | Lua | 16 | v1 | 8 | 3,148 | 9,193 | 148,506 | 160,855 | $0.2104 |
| greenfield | Lua | 16 | v2 | 9 | 3,384 | 17,157 | 202,667 | 223,217 | $0.2932 |
| greenfield | Lua | 17 | v1 | 13 | 3,773 | 12,931 | 297,739 | 314,456 | $0.3241 |
| greenfield | Lua | 17 | v2 | 8 | 2,772 | 15,688 | 156,391 | 174,859 | $0.2456 |
| greenfield | Lua | 18 | v1 | 8 | 4,084 | 10,147 | 150,785 | 165,024 | $0.2410 |
| greenfield | Lua | 18 | v2 | 8 | 2,855 | 17,174 | 160,636 | 180,673 | $0.2591 |
| greenfield | Lua | 19 | v1 | 12 | 5,477 | 12,046 | 268,913 | 286,448 | $0.3467 |
| greenfield | Lua | 19 | v2 | 9 | 3,113 | 16,391 | 204,099 | 223,612 | $0.2824 |
| greenfield | Lua | 20 | v1 | 14 | 5,702 | 12,187 | 328,588 | 346,491 | $0.3831 |
| greenfield | Lua | 20 | v2 | 9 | 2,809 | 16,901 | 194,752 | 214,471 | $0.2733 |
| greenfield | Ocaml | 1 | v1 | 13 | 7,262 | 13,384 | 311,141 | 331,800 | $0.4208 |
| greenfield | Ocaml | 1 | v2 | 8 | 3,161 | 15,602 | 169,536 | 188,307 | $0.2613 |
| greenfield | Ocaml | 2 | v1 | 13 | 8,742 | 14,785 | 321,159 | 344,699 | $0.4716 |
| greenfield | Ocaml | 2 | v2 | 10 | 2,801 | 15,135 | 227,955 | 245,901 | $0.2786 |
| greenfield | Ocaml | 3 | v1 | 14 | 9,986 | 16,160 | 367,765 | 393,925 | $0.5346 |
| greenfield | Ocaml | 3 | v2 | 9 | 3,500 | 16,194 | 202,627 | 222,330 | $0.2901 |
| greenfield | Ocaml | 4 | v1 | 12 | 4,283 | 10,932 | 266,196 | 281,423 | $0.3086 |
| greenfield | Ocaml | 4 | v2 | 8 | 2,543 | 14,583 | 160,795 | 177,929 | $0.2352 |
| greenfield | Ocaml | 5 | v1 | 13 | 4,521 | 10,789 | 295,594 | 310,917 | $0.3283 |
| greenfield | Ocaml | 5 | v2 | 9 | 3,368 | 15,535 | 200,156 | 219,068 | $0.2814 |
| greenfield | Ocaml | 6 | v1 | 12 | 4,200 | 10,927 | 266,634 | 281,773 | $0.3067 |
| greenfield | Ocaml | 6 | v2 | 9 | 3,516 | 15,856 | 201,273 | 220,654 | $0.2877 |
| greenfield | Ocaml | 7 | v1 | 12 | 4,082 | 10,658 | 265,529 | 280,281 | $0.3015 |
| greenfield | Ocaml | 7 | v2 | 9 | 2,773 | 14,937 | 199,162 | 216,881 | $0.2623 |
| greenfield | Ocaml | 8 | v1 | 11 | 3,979 | 10,265 | 229,283 | 243,538 | $0.2783 |
| greenfield | Ocaml | 8 | v2 | 8 | 2,431 | 14,468 | 160,586 | 177,493 | $0.2315 |
| greenfield | Ocaml | 9 | v1 | 12 | 4,241 | 10,865 | 265,851 | 280,969 | $0.3069 |
| greenfield | Ocaml | 9 | v2 | 9 | 2,655 | 14,998 | 199,142 | 216,804 | $0.2597 |
| greenfield | Ocaml | 10 | v1 | 12 | 3,036 | 9,287 | 251,555 | 263,890 | $0.2598 |
| greenfield | Ocaml | 10 | v2 | 9 | 3,158 | 15,746 | 201,105 | 220,018 | $0.2780 |
| greenfield | Ocaml | 11 | v1 | 12 | 4,147 | 10,798 | 266,354 | 281,311 | $0.3044 |
| greenfield | Ocaml | 11 | v2 | 9 | 3,239 | 15,751 | 201,142 | 220,141 | $0.2800 |
| greenfield | Ocaml | 12 | v1 | 12 | 4,227 | 11,312 | 267,371 | 282,922 | $0.3101 |
| greenfield | Ocaml | 12 | v2 | 8 | 3,550 | 15,802 | 169,446 | 188,806 | $0.2723 |
| greenfield | Ocaml | 13 | v1 | 12 | 4,084 | 10,545 | 256,255 | 270,896 | $0.2962 |
| greenfield | Ocaml | 13 | v2 | 9 | 3,283 | 15,769 | 201,190 | 220,251 | $0.2813 |
| greenfield | Ocaml | 14 | v1 | 12 | 4,198 | 10,809 | 265,796 | 280,815 | $0.3055 |
| greenfield | Ocaml | 14 | v2 | 8 | 2,382 | 14,400 | 160,419 | 177,209 | $0.2298 |
| greenfield | Ocaml | 15 | v1 | 12 | 4,203 | 10,820 | 265,620 | 280,655 | $0.3056 |
| greenfield | Ocaml | 15 | v2 | 8 | 2,492 | 14,548 | 160,681 | 177,729 | $0.2336 |
| greenfield | Ocaml | 16 | v1 | 12 | 4,160 | 10,379 | 264,375 | 278,926 | $0.3011 |
| greenfield | Ocaml | 16 | v2 | 8 | 2,506 | 14,486 | 160,742 | 177,742 | $0.2336 |
| greenfield | Ocaml | 17 | v1 | 12 | 4,182 | 10,433 | 264,283 | 278,910 | $0.3020 |
| greenfield | Ocaml | 17 | v2 | 8 | 2,545 | 14,837 | 167,579 | 184,969 | $0.2402 |
| greenfield | Ocaml | 18 | v1 | 12 | 4,290 | 10,909 | 266,411 | 281,622 | $0.3087 |
| greenfield | Ocaml | 18 | v2 | 8 | 2,605 | 14,906 | 167,679 | 185,198 | $0.2422 |
| greenfield | Ocaml | 19 | v1 | 7 | 2,456 | 8,631 | 119,954 | 131,048 | $0.1754 |
| greenfield | Ocaml | 19 | v2 | 12 | 3,369 | 11,843 | 263,614 | 278,838 | $0.2901 |
| greenfield | Ocaml | 20 | v1 | 12 | 4,187 | 10,793 | 265,731 | 280,723 | $0.3051 |
| greenfield | Ocaml | 20 | v2 | 8 | 2,386 | 14,419 | 160,467 | 177,280 | $0.2300 |
| greenfield | Perl | 1 | v1 | 7 | 7,899 | 13,701 | 130,178 | 151,785 | $0.3482 |
| greenfield | Perl | 1 | v2 | 6 | 2,873 | 14,983 | 104,944 | 122,806 | $0.2180 |
| greenfield | Perl | 2 | v1 | 7 | 8,763 | 14,625 | 131,964 | 155,359 | $0.3765 |
| greenfield | Perl | 2 | v2 | 7 | 2,512 | 14,807 | 128,677 | 146,003 | $0.2197 |
| greenfield | Perl | 3 | v1 | 7 | 7,659 | 13,495 | 129,798 | 150,959 | $0.3408 |
| greenfield | Perl | 3 | v2 | 9 | 4,146 | 16,720 | 201,796 | 222,671 | $0.3091 |
| greenfield | Perl | 4 | v1 | 10 | 3,537 | 10,203 | 206,283 | 220,033 | $0.2554 |
| greenfield | Perl | 4 | v2 | 6 | 2,529 | 15,633 | 106,484 | 124,652 | $0.2142 |
| greenfield | Perl | 5 | v1 | 10 | 2,880 | 9,283 | 202,931 | 215,104 | $0.2315 |
| greenfield | Perl | 5 | v2 | 8 | 3,213 | 16,115 | 170,129 | 189,465 | $0.2661 |
| greenfield | Perl | 6 | v1 | 12 | 4,358 | 10,829 | 263,900 | 279,099 | $0.3086 |
| greenfield | Perl | 6 | v2 | 9 | 2,767 | 15,618 | 201,045 | 219,439 | $0.2674 |
| greenfield | Perl | 7 | v1 | 8 | 2,873 | 8,953 | 147,747 | 159,581 | $0.2017 |
| greenfield | Perl | 7 | v2 | 8 | 3,206 | 16,333 | 170,723 | 190,270 | $0.2676 |
| greenfield | Perl | 8 | v1 | 7 | 2,604 | 8,619 | 119,997 | 131,227 | $0.1790 |
| greenfield | Perl | 8 | v2 | 6 | 2,766 | 15,562 | 106,250 | 124,584 | $0.2196 |
| greenfield | Perl | 9 | v1 | 11 | 3,746 | 10,284 | 234,569 | 248,610 | $0.2753 |
| greenfield | Perl | 9 | v2 | 7 | 2,911 | 15,891 | 136,170 | 154,979 | $0.2402 |
| greenfield | Perl | 10 | v1 | 12 | 4,525 | 10,792 | 260,346 | 275,675 | $0.3108 |
| greenfield | Perl | 10 | v2 | 9 | 3,219 | 15,727 | 189,276 | 208,231 | $0.2735 |
| greenfield | Perl | 11 | v1 | 9 | 5,752 | 11,905 | 184,328 | 201,994 | $0.3104 |
| greenfield | Perl | 11 | v2 | 8 | 2,530 | 14,763 | 154,067 | 171,368 | $0.2326 |
| greenfield | Perl | 12 | v1 | 21 | 12,670 | 25,861 | 606,244 | 644,796 | $0.7816 |
| greenfield | Perl | 12 | v2 | 8 | 2,419 | 15,573 | 171,997 | 189,997 | $0.2438 |
| greenfield | Perl | 13 | v1 | 13 | 5,410 | 11,923 | 297,939 | 315,285 | $0.3588 |
| greenfield | Perl | 13 | v2 | 9 | 2,413 | 15,158 | 188,777 | 206,357 | $0.2495 |
| greenfield | Perl | 14 | v1 | 8 | 3,323 | 9,384 | 148,206 | 160,921 | $0.2159 |
| greenfield | Perl | 14 | v2 | 8 | 2,638 | 15,810 | 156,990 | 175,446 | $0.2433 |
| greenfield | Perl | 15 | v1 | 9 | 2,972 | 9,573 | 176,476 | 189,030 | $0.2224 |
| greenfield | Perl | 15 | v2 | 8 | 3,385 | 16,647 | 171,421 | 191,461 | $0.2744 |
| greenfield | Perl | 16 | v1 | 10 | 4,803 | 11,014 | 208,298 | 224,125 | $0.2931 |
| greenfield | Perl | 16 | v2 | 7 | 2,903 | 15,833 | 136,049 | 154,792 | $0.2396 |
| greenfield | Perl | 17 | v1 | 8 | 3,050 | 9,210 | 148,164 | 160,432 | $0.2079 |
| greenfield | Perl | 17 | v2 | 8 | 2,443 | 15,618 | 166,868 | 184,937 | $0.2422 |
| greenfield | Perl | 18 | v1 | 9 | 3,463 | 9,803 | 177,706 | 190,981 | $0.2367 |
| greenfield | Perl | 18 | v2 | 7 | 2,654 | 16,244 | 140,406 | 159,311 | $0.2381 |
| greenfield | Perl | 19 | v1 | 13 | 4,305 | 13,372 | 306,033 | 323,723 | $0.3443 |
| greenfield | Perl | 19 | v2 | 8 | 3,355 | 16,534 | 171,400 | 191,297 | $0.2730 |
| greenfield | Perl | 20 | v1 | 10 | 3,771 | 10,833 | 206,504 | 221,118 | $0.2653 |
| greenfield | Perl | 20 | v2 | 8 | 2,585 | 15,814 | 166,192 | 184,599 | $0.2466 |
| greenfield | Python | 1 | v1 | 7 | 1,905 | 7,855 | 118,494 | 128,261 | $0.1560 |
| greenfield | Python | 1 | v2 | 7 | 2,586 | 14,468 | 136,166 | 153,227 | $0.2232 |
| greenfield | Python | 2 | v1 | 7 | 1,844 | 7,786 | 118,366 | 128,003 | $0.1540 |
| greenfield | Python | 2 | v2 | 7 | 2,597 | 14,461 | 127,902 | 144,967 | $0.2193 |
| greenfield | Python | 3 | v1 | 7 | 1,917 | 7,852 | 118,484 | 128,260 | $0.1563 |
| greenfield | Python | 3 | v2 | 7 | 3,129 | 15,097 | 134,366 | 152,599 | $0.2398 |
| greenfield | Python | 4 | v1 | 7 | 1,838 | 7,780 | 118,356 | 127,981 | $0.1538 |
| greenfield | Python | 4 | v2 | 7 | 2,662 | 14,477 | 136,370 | 153,516 | $0.2253 |
| greenfield | Python | 5 | v1 | 7 | 1,847 | 7,801 | 118,398 | 128,053 | $0.1542 |
| greenfield | Python | 5 | v2 | 8 | 3,120 | 9,504 | 144,325 | 156,957 | $0.2096 |
| greenfield | Python | 6 | v1 | 7 | 1,880 | 7,825 | 118,434 | 128,146 | $0.1552 |
| greenfield | Python | 6 | v2 | 6 | 2,574 | 14,305 | 103,908 | 120,793 | $0.2057 |
| greenfield | Python | 7 | v1 | 7 | 1,885 | 7,830 | 118,448 | 128,170 | $0.1553 |
| greenfield | Python | 7 | v2 | 6 | 2,470 | 14,213 | 103,800 | 120,489 | $0.2025 |
| greenfield | Python | 8 | v1 | 7 | 1,804 | 7,753 | 118,292 | 127,856 | $0.1527 |
| greenfield | Python | 8 | v2 | 6 | 2,491 | 14,137 | 103,622 | 120,256 | $0.2025 |
| greenfield | Python | 9 | v1 | 7 | 1,804 | 7,753 | 118,298 | 127,862 | $0.1527 |
| greenfield | Python | 9 | v2 | 9 | 2,336 | 14,279 | 185,320 | 201,944 | $0.2403 |
| greenfield | Python | 10 | v1 | 7 | 1,837 | 7,781 | 118,356 | 127,981 | $0.1538 |
| greenfield | Python | 10 | v2 | 8 | 2,841 | 14,700 | 162,367 | 179,916 | $0.2441 |
| greenfield | Python | 11 | v1 | 7 | 1,862 | 7,820 | 118,441 | 128,130 | $0.1547 |
| greenfield | Python | 11 | v2 | 9 | 2,423 | 14,515 | 186,067 | 203,014 | $0.2444 |
| greenfield | Python | 12 | v1 | 7 | 2,003 | 7,938 | 118,679 | 128,627 | $0.1591 |
| greenfield | Python | 12 | v2 | 9 | 3,218 | 15,519 | 188,159 | 206,905 | $0.2716 |
| greenfield | Python | 13 | v1 | 7 | 1,887 | 7,834 | 118,466 | 128,194 | $0.1554 |
| greenfield | Python | 13 | v2 | 8 | 2,878 | 14,976 | 167,065 | 184,927 | $0.2491 |
| greenfield | Python | 14 | v1 | 7 | 1,779 | 7,741 | 118,274 | 127,801 | $0.1520 |
| greenfield | Python | 14 | v2 | 9 | 2,323 | 14,279 | 185,305 | 201,916 | $0.2400 |
| greenfield | Python | 15 | v1 | 7 | 1,838 | 7,778 | 118,348 | 127,971 | $0.1538 |
| greenfield | Python | 15 | v2 | 7 | 2,583 | 14,333 | 127,555 | 144,478 | $0.2180 |
| greenfield | Python | 16 | v1 | 7 | 2,119 | 8,058 | 118,908 | 129,092 | $0.1628 |
| greenfield | Python | 16 | v2 | 9 | 2,898 | 15,277 | 187,833 | 206,017 | $0.2619 |
| greenfield | Python | 17 | v1 | 7 | 1,886 | 7,835 | 118,460 | 128,188 | $0.1554 |
| greenfield | Python | 17 | v2 | 6 | 2,449 | 14,209 | 103,839 | 120,503 | $0.2020 |
| greenfield | Python | 18 | v1 | 7 | 1,807 | 7,754 | 118,302 | 127,870 | $0.1528 |
| greenfield | Python | 18 | v2 | 8 | 2,744 | 9,097 | 143,725 | 155,574 | $0.1974 |
| greenfield | Python | 19 | v1 | 7 | 2,030 | 7,965 | 118,722 | 128,724 | $0.1599 |
| greenfield | Python | 19 | v2 | 6 | 2,356 | 14,352 | 104,192 | 120,906 | $0.2007 |
| greenfield | Python | 20 | v1 | 7 | 1,836 | 7,794 | 118,380 | 128,017 | $0.1538 |
| greenfield | Python | 20 | v2 | 8 | 2,987 | 9,380 | 144,069 | 156,444 | $0.2054 |
| greenfield | Python/mypy | 1 | v1 | 10 | 2,820 | 8,835 | 200,394 | 212,059 | $0.2260 |
| greenfield | Python/mypy | 1 | v2 | 13 | 4,746 | 17,422 | 345,008 | 367,189 | $0.4001 |
| greenfield | Python/mypy | 2 | v1 | 8 | 2,688 | 8,657 | 147,622 | 158,975 | $0.1952 |
| greenfield | Python/mypy | 2 | v2 | 12 | 4,409 | 11,649 | 267,832 | 283,902 | $0.3170 |
| greenfield | Python/mypy | 3 | v1 | 12 | 3,298 | 12,105 | 266,511 | 281,926 | $0.2914 |
| greenfield | Python/mypy | 3 | v2 | 15 | 5,000 | 17,780 | 413,585 | 436,380 | $0.4430 |
| greenfield | Python/mypy | 4 | v1 | 9 | 2,539 | 8,711 | 174,427 | 185,686 | $0.2052 |
| greenfield | Python/mypy | 4 | v2 | 7 | 3,714 | 16,462 | 136,200 | 156,383 | $0.2639 |
| greenfield | Python/mypy | 5 | v1 | 8 | 3,720 | 9,995 | 149,188 | 162,911 | $0.2301 |
| greenfield | Python/mypy | 5 | v2 | 12 | 4,997 | 19,503 | 323,299 | 347,811 | $0.4085 |
| greenfield | Python/mypy | 6 | v1 | 13 | 3,209 | 9,586 | 287,154 | 299,962 | $0.2838 |
| greenfield | Python/mypy | 6 | v2 | 12 | 4,412 | 11,494 | 265,212 | 281,130 | $0.3148 |
| greenfield | Python/mypy | 7 | v1 | 9 | 3,962 | 10,080 | 178,464 | 192,515 | $0.2513 |
| greenfield | Python/mypy | 7 | v2 | 14 | 5,235 | 16,389 | 359,737 | 381,375 | $0.4132 |
| greenfield | Python/mypy | 8 | v1 | 9 | 2,364 | 8,523 | 173,731 | 184,627 | $0.1993 |
| greenfield | Python/mypy | 8 | v2 | 11 | 4,561 | 11,298 | 235,471 | 251,341 | $0.3024 |
| greenfield | Python/mypy | 9 | v1 | 12 | 3,033 | 9,401 | 258,346 | 270,792 | $0.2638 |
| greenfield | Python/mypy | 9 | v2 | 14 | 4,680 | 17,634 | 362,191 | 384,519 | $0.4084 |
| greenfield | Python/mypy | 10 | v1 | 9 | 2,474 | 8,627 | 174,089 | 185,199 | $0.2029 |
| greenfield | Python/mypy | 10 | v2 | 11 | 4,557 | 11,778 | 238,222 | 254,568 | $0.3067 |
| greenfield | Python/mypy | 11 | v1 | 9 | 3,952 | 10,119 | 178,447 | 192,527 | $0.2513 |
| greenfield | Python/mypy | 11 | v2 | 10 | 4,253 | 18,452 | 236,558 | 259,273 | $0.3400 |
| greenfield | Python/mypy | 12 | v1 | 9 | 2,470 | 8,641 | 174,137 | 185,257 | $0.2029 |
| greenfield | Python/mypy | 12 | v2 | 13 | 4,980 | 14,024 | 307,017 | 326,034 | $0.3657 |
| greenfield | Python/mypy | 13 | v1 | 9 | 2,391 | 8,558 | 173,700 | 184,658 | $0.2002 |
| greenfield | Python/mypy | 13 | v2 | 13 | 4,382 | 16,807 | 342,921 | 364,123 | $0.3861 |
| greenfield | Python/mypy | 14 | v1 | 9 | 2,278 | 8,445 | 173,453 | 184,185 | $0.1965 |
| greenfield | Python/mypy | 14 | v2 | 11 | 4,370 | 10,912 | 233,332 | 248,625 | $0.2942 |
| greenfield | Python/mypy | 15 | v1 | 13 | 3,032 | 9,388 | 283,736 | 296,169 | $0.2764 |
| greenfield | Python/mypy | 15 | v2 | 11 | 4,441 | 11,155 | 234,554 | 250,161 | $0.2981 |
| greenfield | Python/mypy | 16 | v1 | 9 | 2,370 | 8,526 | 173,680 | 184,585 | $0.1994 |
| greenfield | Python/mypy | 16 | v2 | 10 | 4,499 | 11,479 | 206,278 | 222,266 | $0.2874 |
| greenfield | Python/mypy | 17 | v1 | 9 | 2,316 | 8,755 | 173,932 | 185,012 | $0.1996 |
| greenfield | Python/mypy | 17 | v2 | 10 | 4,636 | 11,292 | 204,376 | 220,314 | $0.2887 |
| greenfield | Python/mypy | 18 | v1 | 9 | 4,229 | 10,396 | 179,417 | 194,051 | $0.2605 |
| greenfield | Python/mypy | 18 | v2 | 10 | 4,447 | 13,648 | 215,032 | 233,137 | $0.3040 |
| greenfield | Python/mypy | 19 | v1 | 9 | 2,616 | 8,970 | 175,011 | 186,606 | $0.2090 |
| greenfield | Python/mypy | 19 | v2 | 9 | 3,827 | 18,042 | 202,453 | 224,331 | $0.3097 |
| greenfield | Python/mypy | 20 | v1 | 13 | 2,832 | 11,070 | 291,717 | 305,632 | $0.2859 |
| greenfield | Python/mypy | 20 | v2 | 11 | 4,280 | 10,841 | 232,847 | 247,979 | $0.2912 |
| greenfield | Ruby | 1 | v1 | 7 | 1,882 | 7,812 | 118,456 | 128,157 | $0.1551 |
| greenfield | Ruby | 1 | v2 | 7 | 2,163 | 13,874 | 127,075 | 143,119 | $0.2044 |
| greenfield | Ruby | 2 | v1 | 7 | 1,994 | 7,885 | 118,480 | 128,366 | $0.1584 |
| greenfield | Ruby | 2 | v2 | 7 | 2,672 | 14,422 | 133,519 | 150,620 | $0.2237 |
| greenfield | Ruby | 3 | v1 | 2,493 | 1,829 | 7,757 | 115,746 | 127,825 | $0.1645 |
| greenfield | Ruby | 3 | v2 | 6 | 2,201 | 13,922 | 103,504 | 119,633 | $0.1938 |
| greenfield | Ruby | 4 | v1 | 7 | 1,566 | 7,509 | 117,810 | 126,892 | $0.1450 |
| greenfield | Ruby | 4 | v2 | 7 | 2,472 | 14,017 | 132,871 | 149,367 | $0.2159 |
| greenfield | Ruby | 5 | v1 | 7 | 1,571 | 7,508 | 117,732 | 126,818 | $0.1451 |
| greenfield | Ruby | 5 | v2 | 7 | 2,359 | 13,875 | 132,713 | 148,954 | $0.2121 |
| greenfield | Ruby | 6 | v1 | 7 | 1,536 | 7,496 | 117,790 | 126,829 | $0.1442 |
| greenfield | Ruby | 6 | v2 | 7 | 2,446 | 13,989 | 132,843 | 149,285 | $0.2150 |
| greenfield | Ruby | 7 | v1 | 7 | 1,546 | 7,487 | 117,760 | 126,800 | $0.1444 |
| greenfield | Ruby | 7 | v2 | 7 | 2,543 | 14,088 | 132,916 | 149,554 | $0.2181 |
| greenfield | Ruby | 8 | v1 | 7 | 1,486 | 7,510 | 117,814 | 126,817 | $0.1430 |
| greenfield | Ruby | 8 | v2 | 7 | 2,257 | 8,275 | 115,750 | 126,289 | $0.1661 |
| greenfield | Ruby | 9 | v1 | 7 | 1,601 | 7,541 | 117,878 | 127,027 | $0.1461 |
| greenfield | Ruby | 9 | v2 | 7 | 2,588 | 14,217 | 133,141 | 149,953 | $0.2202 |
| greenfield | Ruby | 10 | v1 | 7 | 1,735 | 7,656 | 118,104 | 127,502 | $0.1503 |
| greenfield | Ruby | 10 | v2 | 7 | 2,688 | 14,446 | 133,498 | 150,639 | $0.2243 |
| greenfield | Ruby | 11 | v1 | 7 | 1,752 | 7,693 | 118,102 | 127,554 | $0.1510 |
| greenfield | Ruby | 11 | v2 | 8 | 1,835 | 8,177 | 142,140 | 152,160 | $0.1681 |
| greenfield | Ruby | 12 | v1 | 7 | 1,721 | 7,660 | 118,100 | 127,488 | $0.1500 |
| greenfield | Ruby | 12 | v2 | 8 | 2,775 | 14,729 | 166,442 | 183,954 | $0.2447 |
| greenfield | Ruby | 13 | v1 | 7 | 1,757 | 7,710 | 118,135 | 127,609 | $0.1512 |
| greenfield | Ruby | 13 | v2 | 7 | 2,726 | 14,511 | 133,575 | 150,819 | $0.2257 |
| greenfield | Ruby | 14 | v1 | 7 | 1,510 | 7,477 | 117,751 | 126,745 | $0.1434 |
| greenfield | Ruby | 14 | v2 | 7 | 1,884 | 13,375 | 126,350 | 141,616 | $0.1939 |
| greenfield | Ruby | 15 | v1 | 7 | 1,633 | 7,600 | 118,000 | 127,240 | $0.1474 |
| greenfield | Ruby | 15 | v2 | 8 | 2,015 | 13,828 | 152,334 | 168,185 | $0.2130 |
| greenfield | Ruby | 16 | v1 | 7 | 1,554 | 7,498 | 117,716 | 126,775 | $0.1446 |
| greenfield | Ruby | 16 | v2 | 7 | 2,376 | 13,839 | 132,628 | 148,850 | $0.2122 |
| greenfield | Ruby | 17 | v1 | 7 | 1,532 | 7,493 | 117,778 | 126,810 | $0.1441 |
| greenfield | Ruby | 17 | v2 | 7 | 2,392 | 13,944 | 132,814 | 149,157 | $0.2134 |
| greenfield | Ruby | 18 | v1 | 7 | 1,581 | 7,535 | 117,864 | 126,987 | $0.1456 |
| greenfield | Ruby | 18 | v2 | 8 | 2,751 | 14,581 | 160,411 | 177,751 | $0.2402 |
| greenfield | Ruby | 19 | v1 | 7 | 1,686 | 7,622 | 118,049 | 127,364 | $0.1488 |
| greenfield | Ruby | 19 | v2 | 7 | 2,211 | 13,969 | 133,047 | 149,234 | $0.2091 |
| greenfield | Ruby | 20 | v1 | 7 | 1,783 | 7,716 | 118,156 | 127,662 | $0.1519 |
| greenfield | Ruby | 20 | v2 | 8 | 2,098 | 13,996 | 152,631 | 168,733 | $0.2163 |
| greenfield | Ruby/steep | 1 | v1 | 19 | 2,903 | 11,139 | 463,912 | 477,973 | $0.3742 |
| greenfield | Ruby/steep | 1 | v2 | 18 | 5,236 | 18,175 | 521,716 | 545,145 | $0.5054 |
| greenfield | Ruby/steep | 2 | v1 | 18 | 3,991 | 10,489 | 428,352 | 442,850 | $0.3796 |
| greenfield | Ruby/steep | 2 | v2 | 15 | 5,329 | 18,230 | 416,956 | 440,530 | $0.4557 |
| greenfield | Ruby/steep | 3 | v1 | 19 | 4,655 | 11,262 | 461,934 | 477,870 | $0.4178 |
| greenfield | Ruby/steep | 3 | v2 | 16 | 4,941 | 17,847 | 440,345 | 463,149 | $0.4553 |
| greenfield | Ruby/steep | 4 | v1 | 23 | 5,894 | 15,078 | 598,685 | 619,680 | $0.5410 |
| greenfield | Ruby/steep | 4 | v2 | 16 | 4,652 | 11,656 | 377,958 | 394,282 | $0.3782 |
| greenfield | Ruby/steep | 5 | v1 | 17 | 3,621 | 10,214 | 395,775 | 409,627 | $0.3523 |
| greenfield | Ruby/steep | 5 | v2 | 15 | 4,216 | 11,449 | 350,341 | 366,021 | $0.3522 |
| greenfield | Ruby/steep | 6 | v1 | 24 | 5,830 | 15,047 | 627,919 | 648,820 | $0.5539 |
| greenfield | Ruby/steep | 6 | v2 | 11 | 3,996 | 16,544 | 251,092 | 271,643 | $0.3289 |
| greenfield | Ruby/steep | 7 | v1 | 17 | 3,579 | 10,146 | 394,994 | 408,736 | $0.3505 |
| greenfield | Ruby/steep | 7 | v2 | 19 | 5,095 | 18,156 | 535,642 | 558,912 | $0.5088 |
| greenfield | Ruby/steep | 8 | v1 | 22 | 5,349 | 14,382 | 564,174 | 583,927 | $0.5058 |
| greenfield | Ruby/steep | 8 | v2 | 88 | 3,958 | 18,115 | 325,994 | 348,155 | $0.3756 |
| greenfield | Ruby/steep | 9 | v1 | 25 | 4,889 | 13,595 | 646,145 | 664,654 | $0.5304 |
| greenfield | Ruby/steep | 9 | v2 | 17 | 4,528 | 17,270 | 469,953 | 491,768 | $0.4562 |
| greenfield | Ruby/steep | 10 | v1 | 21 | 4,375 | 11,636 | 518,132 | 534,164 | $0.4413 |
| greenfield | Ruby/steep | 10 | v2 | 15 | 4,226 | 16,870 | 398,553 | 419,664 | $0.4104 |
| greenfield | Ruby/steep | 11 | v1 | 20 | 3,894 | 12,394 | 501,652 | 517,960 | $0.4257 |
| greenfield | Ruby/steep | 11 | v2 | 14 | 5,052 | 12,152 | 328,219 | 345,437 | $0.3664 |
| greenfield | Ruby/steep | 12 | v1 | 16 | 3,700 | 10,054 | 368,311 | 382,081 | $0.3396 |
| greenfield | Ruby/steep | 12 | v2 | 17 | 4,289 | 17,273 | 459,700 | 481,279 | $0.4451 |
| greenfield | Ruby/steep | 13 | v1 | 18 | 3,909 | 10,406 | 426,575 | 440,908 | $0.3761 |
| greenfield | Ruby/steep | 13 | v2 | 15 | 5,171 | 18,085 | 417,850 | 441,121 | $0.4513 |
| greenfield | Ruby/steep | 14 | v1 | 19 | 3,937 | 11,412 | 460,022 | 475,390 | $0.3999 |
| greenfield | Ruby/steep | 14 | v2 | 94 | 4,128 | 16,517 | 395,286 | 416,025 | $0.4045 |
| greenfield | Ruby/steep | 15 | v1 | 20 | 4,091 | 10,939 | 486,417 | 501,467 | $0.4140 |
| greenfield | Ruby/steep | 15 | v2 | 16 | 4,553 | 17,208 | 434,362 | 456,139 | $0.4386 |
| greenfield | Ruby/steep | 16 | v1 | 21 | 4,241 | 11,361 | 516,141 | 531,764 | $0.4352 |
| greenfield | Ruby/steep | 16 | v2 | 15 | 4,197 | 16,744 | 397,004 | 417,960 | $0.4082 |
| greenfield | Ruby/steep | 17 | v1 | 18 | 3,955 | 10,780 | 428,331 | 443,084 | $0.3805 |
| greenfield | Ruby/steep | 17 | v2 | 14 | 4,289 | 11,381 | 322,415 | 338,099 | $0.3396 |
| greenfield | Ruby/steep | 18 | v1 | 17 | 4,023 | 10,631 | 397,686 | 412,357 | $0.3659 |
| greenfield | Ruby/steep | 18 | v2 | 16 | 4,271 | 11,615 | 376,609 | 392,511 | $0.3678 |
| greenfield | Ruby/steep | 19 | v1 | 23 | 5,766 | 14,908 | 598,058 | 618,755 | $0.5365 |
| greenfield | Ruby/steep | 19 | v2 | 94 | 4,612 | 17,322 | 529,429 | 551,457 | $0.4887 |
| greenfield | Ruby/steep | 20 | v1 | 20 | 4,220 | 11,334 | 487,893 | 503,467 | $0.4204 |
| greenfield | Ruby/steep | 20 | v2 | 90 | 3,372 | 17,390 | 262,338 | 283,190 | $0.3246 |
| greenfield | Rust | 1 | v1 | 19 | 11,489 | 17,790 | 470,356 | 499,654 | $0.6337 |
| greenfield | Rust | 1 | v2 | 13 | 7,866 | 21,521 | 350,691 | 380,091 | $0.5066 |
| greenfield | Rust | 2 | v1 | 11 | 3,161 | 9,383 | 226,016 | 238,571 | $0.2507 |
| greenfield | Rust | 2 | v2 | 12 | 4,481 | 17,054 | 303,648 | 325,195 | $0.3705 |
| greenfield | Rust | 3 | v1 | 15 | 3,642 | 9,864 | 339,065 | 352,586 | $0.3223 |
| greenfield | Rust | 3 | v2 | 11 | 4,405 | 17,632 | 272,814 | 294,862 | $0.3568 |
| greenfield | Rust | 4 | v1 | 12 | 2,956 | 9,095 | 255,954 | 268,017 | $0.2588 |
| greenfield | Rust | 4 | v2 | 10 | 4,340 | 17,085 | 239,295 | 260,730 | $0.3350 |
| greenfield | Rust | 5 | v1 | 10 | 4,180 | 10,407 | 203,688 | 218,285 | $0.2714 |
| greenfield | Rust | 5 | v2 | 12 | 4,620 | 13,441 | 271,432 | 289,505 | $0.3353 |
| greenfield | Rust | 6 | v1 | 7 | 2,380 | 8,580 | 119,720 | 130,687 | $0.1730 |
| greenfield | Rust | 6 | v2 | 9 | 3,409 | 16,060 | 190,708 | 210,186 | $0.2810 |
| greenfield | Rust | 7 | v1 | 7 | 2,339 | 8,554 | 119,696 | 130,596 | $0.1718 |
| greenfield | Rust | 7 | v2 | 9 | 4,424 | 17,520 | 206,044 | 227,997 | $0.3232 |
| greenfield | Rust | 8 | v1 | 7 | 2,418 | 8,535 | 119,840 | 130,800 | $0.1737 |
| greenfield | Rust | 8 | v2 | 8 | 3,261 | 15,628 | 163,240 | 182,137 | $0.2609 |
| greenfield | Rust | 9 | v1 | 7 | 2,318 | 8,312 | 119,437 | 130,074 | $0.1697 |
| greenfield | Rust | 9 | v2 | 14 | 3,608 | 18,297 | 373,312 | 395,231 | $0.3913 |
| greenfield | Rust | 10 | v1 | 8 | 2,572 | 8,804 | 145,523 | 156,907 | $0.1921 |
| greenfield | Rust | 10 | v2 | 8 | 3,285 | 15,738 | 163,525 | 182,556 | $0.2623 |
| greenfield | Rust | 11 | v1 | 7 | 2,375 | 8,602 | 119,751 | 130,735 | $0.1730 |
| greenfield | Rust | 11 | v2 | 9 | 3,885 | 17,043 | 202,267 | 223,204 | $0.3048 |
| greenfield | Rust | 12 | v1 | 8 | 2,696 | 8,872 | 147,315 | 158,891 | $0.1965 |
| greenfield | Rust | 12 | v2 | 10 | 3,241 | 16,283 | 226,043 | 245,577 | $0.2959 |
| greenfield | Rust | 13 | v1 | 7 | 2,347 | 8,566 | 119,681 | 130,601 | $0.1721 |
| greenfield | Rust | 13 | v2 | 8 | 3,233 | 16,227 | 165,770 | 185,238 | $0.2652 |
| greenfield | Rust | 14 | v1 | 7 | 2,458 | 8,662 | 119,872 | 130,999 | $0.1756 |
| greenfield | Rust | 14 | v2 | 7 | 3,207 | 16,211 | 131,223 | 150,648 | $0.2471 |
| greenfield | Rust | 15 | v1 | 6 | 2,210 | 8,215 | 92,304 | 102,735 | $0.1528 |
| greenfield | Rust | 15 | v2 | 10 | 4,080 | 16,740 | 238,046 | 258,876 | $0.3257 |
| greenfield | Rust | 16 | v1 | 12 | 4,404 | 10,710 | 255,331 | 270,457 | $0.3048 |
| greenfield | Rust | 16 | v2 | 10 | 2,960 | 15,535 | 222,923 | 241,428 | $0.2826 |
| greenfield | Rust | 17 | v1 | 7 | 2,396 | 8,625 | 119,804 | 130,832 | $0.1737 |
| greenfield | Rust | 17 | v2 | 8 | 3,270 | 15,653 | 163,283 | 182,214 | $0.2613 |
| greenfield | Rust | 18 | v1 | 7 | 2,186 | 8,181 | 117,517 | 127,891 | $0.1646 |
| greenfield | Rust | 18 | v2 | 8 | 3,183 | 15,474 | 162,078 | 180,743 | $0.2574 |
| greenfield | Rust | 19 | v1 | 9 | 2,613 | 9,056 | 173,193 | 184,871 | $0.2086 |
| greenfield | Rust | 19 | v2 | 9 | 3,009 | 16,192 | 205,053 | 224,263 | $0.2790 |
| greenfield | Rust | 20 | v1 | 7 | 2,185 | 8,188 | 117,523 | 127,903 | $0.1646 |
| greenfield | Rust | 20 | v2 | 11 | 4,117 | 16,758 | 272,802 | 293,688 | $0.3441 |
| greenfield | Scheme | 1 | v1 | 15 | 13,958 | 20,458 | 422,068 | 456,499 | $0.6879 |
| greenfield | Scheme | 1 | v2 | 12 | 4,316 | 19,855 | 320,024 | 344,207 | $0.3921 |
| greenfield | Scheme | 2 | v1 | 12 | 3,784 | 10,235 | 259,061 | 273,092 | $0.2882 |
| greenfield | Scheme | 2 | v2 | 13 | 4,079 | 19,949 | 354,007 | 378,048 | $0.4037 |
| greenfield | Scheme | 3 | v1 | 13 | 4,491 | 11,633 | 291,832 | 307,969 | $0.3310 |
| greenfield | Scheme | 3 | v2 | 14 | 4,918 | 20,917 | 394,161 | 420,010 | $0.4508 |
| greenfield | Scheme | 4 | v1 | 9 | 3,040 | 9,451 | 176,523 | 189,023 | $0.2234 |
| greenfield | Scheme | 4 | v2 | 7 | 2,861 | 15,783 | 129,903 | 148,554 | $0.2352 |
| greenfield | Scheme | 5 | v1 | 8 | 2,949 | 10,038 | 149,005 | 162,000 | $0.2110 |
| greenfield | Scheme | 5 | v2 | 9 | 3,507 | 18,735 | 203,766 | 226,017 | $0.3067 |
| greenfield | Scheme | 6 | v1 | 7 | 2,775 | 9,187 | 120,638 | 132,607 | $0.1871 |
| greenfield | Scheme | 6 | v2 | 9 | 3,611 | 20,639 | 206,811 | 231,070 | $0.3227 |
| greenfield | Scheme | 7 | v1 | 7 | 2,718 | 8,959 | 120,617 | 132,301 | $0.1843 |
| greenfield | Scheme | 7 | v2 | 10 | 3,256 | 18,862 | 238,257 | 260,385 | $0.3185 |
| greenfield | Scheme | 8 | v1 | 6 | 2,671 | 8,832 | 93,013 | 104,522 | $0.1685 |
| greenfield | Scheme | 8 | v2 | 9 | 3,570 | 18,958 | 204,359 | 226,896 | $0.3100 |
| greenfield | Scheme | 9 | v1 | 7 | 2,767 | 9,118 | 120,485 | 132,377 | $0.1864 |
| greenfield | Scheme | 9 | v2 | 12 | 4,017 | 21,111 | 321,119 | 346,259 | $0.3930 |
| greenfield | Scheme | 10 | v1 | 8 | 2,574 | 8,679 | 145,167 | 156,428 | $0.1912 |
| greenfield | Scheme | 10 | v2 | 10 | 3,620 | 18,880 | 243,878 | 266,388 | $0.3305 |
| greenfield | Scheme | 11 | v1 | 9 | 3,015 | 9,333 | 173,741 | 186,098 | $0.2206 |
| greenfield | Scheme | 11 | v2 | 9 | 3,461 | 18,886 | 210,125 | 232,481 | $0.3097 |
| greenfield | Scheme | 12 | v1 | 8 | 3,015 | 9,551 | 148,860 | 161,434 | $0.2095 |
| greenfield | Scheme | 12 | v2 | 11 | 3,649 | 19,675 | 274,230 | 297,565 | $0.3514 |
| greenfield | Scheme | 13 | v1 | 12 | 3,670 | 10,839 | 260,952 | 275,473 | $0.2900 |
| greenfield | Scheme | 13 | v2 | 13 | 4,220 | 19,636 | 352,449 | 376,318 | $0.4045 |
| greenfield | Scheme | 14 | v1 | 10 | 3,126 | 9,456 | 201,875 | 214,467 | $0.2382 |
| greenfield | Scheme | 14 | v2 | 9 | 3,588 | 19,138 | 205,110 | 227,845 | $0.3119 |
| greenfield | Scheme | 15 | v1 | 11 | 3,530 | 10,924 | 231,798 | 246,263 | $0.2725 |
| greenfield | Scheme | 15 | v2 | 7 | 3,103 | 16,065 | 130,228 | 149,403 | $0.2431 |
| greenfield | Scheme | 16 | v1 | 10 | 3,398 | 10,103 | 205,582 | 219,093 | $0.2509 |
| greenfield | Scheme | 16 | v2 | 10 | 3,984 | 19,439 | 246,468 | 269,901 | $0.3444 |
| greenfield | Scheme | 17 | v1 | 9 | 3,017 | 9,348 | 173,824 | 186,198 | $0.2208 |
| greenfield | Scheme | 17 | v2 | 11 | 3,201 | 21,223 | 282,211 | 306,646 | $0.3538 |
| greenfield | Scheme | 18 | v1 | 9 | 3,188 | 9,582 | 177,239 | 190,018 | $0.2283 |
| greenfield | Scheme | 18 | v2 | 13 | 4,442 | 20,076 | 354,997 | 379,528 | $0.4141 |
| greenfield | Scheme | 19 | v1 | 10 | 3,423 | 9,750 | 202,686 | 215,869 | $0.2479 |
| greenfield | Scheme | 19 | v2 | 13 | 4,451 | 21,660 | 360,798 | 386,922 | $0.4271 |
| greenfield | Scheme | 20 | v1 | 8 | 3,095 | 9,871 | 149,409 | 162,383 | $0.2138 |
| greenfield | Scheme | 20 | v2 | 11 | 3,861 | 21,851 | 291,102 | 316,825 | $0.3787 |
| greenfield | Typescript | 1 | v1 | 11 | 3,407 | 10,495 | 233,364 | 247,277 | $0.2675 |
| greenfield | Typescript | 1 | v2 | 8 | 2,786 | 15,152 | 162,238 | 180,184 | $0.2455 |
| greenfield | Typescript | 2 | v1 | 10 | 2,969 | 10,654 | 206,500 | 220,133 | $0.2441 |
| greenfield | Typescript | 2 | v2 | 8 | 3,134 | 15,294 | 162,511 | 180,947 | $0.2552 |
| greenfield | Typescript | 3 | v1 | 20 | 6,665 | 14,775 | 532,532 | 553,992 | $0.5253 |
| greenfield | Typescript | 3 | v2 | 13 | 3,528 | 24,533 | 406,497 | 434,571 | $0.4448 |
| greenfield | Typescript | 4 | v1 | 15 | 3,880 | 10,664 | 347,145 | 361,704 | $0.3373 |
| greenfield | Typescript | 4 | v2 | 8 | 3,123 | 15,314 | 162,550 | 180,995 | $0.2551 |
| greenfield | Typescript | 5 | v1 | 11 | 2,358 | 9,342 | 228,124 | 239,835 | $0.2315 |
| greenfield | Typescript | 5 | v2 | 11 | 2,917 | 23,142 | 314,364 | 340,434 | $0.3748 |
| greenfield | Typescript | 6 | v1 | 12 | 2,735 | 9,913 | 258,340 | 271,000 | $0.2596 |
| greenfield | Typescript | 6 | v2 | 8 | 2,498 | 14,643 | 161,186 | 178,335 | $0.2346 |
| greenfield | Typescript | 7 | v1 | 10 | 2,516 | 9,883 | 204,522 | 216,931 | $0.2270 |
| greenfield | Typescript | 7 | v2 | 10 | 2,659 | 14,847 | 227,684 | 245,200 | $0.2732 |
| greenfield | Typescript | 8 | v1 | 11 | 2,732 | 10,144 | 231,242 | 244,129 | $0.2474 |
| greenfield | Typescript | 8 | v2 | 10 | 2,783 | 15,074 | 228,613 | 246,480 | $0.2781 |
| greenfield | Typescript | 9 | v1 | 11 | 2,505 | 9,764 | 229,710 | 241,990 | $0.2386 |
| greenfield | Typescript | 9 | v2 | 8 | 2,986 | 15,051 | 161,960 | 180,005 | $0.2497 |
| greenfield | Typescript | 10 | v1 | 15 | 5,750 | 15,064 | 367,828 | 388,657 | $0.4219 |
| greenfield | Typescript | 10 | v2 | 21 | 5,301 | 26,456 | 678,629 | 710,407 | $0.6373 |
| greenfield | Typescript | 11 | v1 | 14 | 3,127 | 11,035 | 317,678 | 331,854 | $0.3061 |
| greenfield | Typescript | 11 | v2 | 10 | 3,163 | 24,704 | 282,214 | 310,091 | $0.3746 |
| greenfield | Typescript | 12 | v1 | 13 | 2,900 | 10,137 | 282,337 | 295,387 | $0.2771 |
| greenfield | Typescript | 12 | v2 | 8 | 3,044 | 15,312 | 162,634 | 180,998 | $0.2532 |
| greenfield | Typescript | 13 | v1 | 12 | 2,694 | 9,400 | 254,011 | 266,117 | $0.2532 |
| greenfield | Typescript | 13 | v2 | 15 | 4,913 | 27,049 | 495,415 | 527,392 | $0.5397 |
| greenfield | Typescript | 14 | v1 | 11 | 2,943 | 10,352 | 232,520 | 245,826 | $0.2546 |
| greenfield | Typescript | 14 | v2 | 11 | 3,066 | 23,646 | 300,042 | 326,765 | $0.3745 |
| greenfield | Typescript | 15 | v1 | 11 | 2,951 | 10,203 | 232,296 | 245,461 | $0.2537 |
| greenfield | Typescript | 15 | v2 | 8 | 3,043 | 15,263 | 162,506 | 180,820 | $0.2528 |
| greenfield | Typescript | 16 | v1 | 11 | 2,495 | 8,921 | 226,488 | 237,915 | $0.2314 |
| greenfield | Typescript | 16 | v2 | 8 | 2,458 | 14,356 | 160,405 | 177,227 | $0.2314 |
| greenfield | Typescript | 17 | v1 | 13 | 2,892 | 10,360 | 285,687 | 298,952 | $0.2800 |
| greenfield | Typescript | 17 | v2 | 10 | 3,155 | 15,338 | 222,192 | 240,695 | $0.2859 |
| greenfield | Typescript | 18 | v1 | 14 | 3,000 | 9,733 | 312,168 | 324,915 | $0.2920 |
| greenfield | Typescript | 18 | v2 | 12 | 3,140 | 23,465 | 355,570 | 382,187 | $0.4030 |
| greenfield | Typescript | 19 | v1 | 13 | 2,944 | 10,370 | 283,463 | 296,790 | $0.2802 |
| greenfield | Typescript | 19 | v2 | 10 | 2,823 | 23,641 | 266,115 | 292,589 | $0.3514 |
| greenfield | Typescript | 20 | v1 | 11 | 2,564 | 9,185 | 229,501 | 241,261 | $0.2363 |
| greenfield | Typescript | 20 | v2 | 11 | 3,152 | 25,253 | 313,832 | 342,248 | $0.3936 |

