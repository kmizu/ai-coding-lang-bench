(defproject minigit "0.1.0"
  :description "MiniGit benchmark"
  :dependencies [[org.clojure/clojure "1.12.0"]]
  :main minigit.core
  :aot [minigit.core]
  :target-path "target/%s"
  :uberjar-name "minigit-standalone.jar")
