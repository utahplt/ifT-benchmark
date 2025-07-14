(defproject typed-clojure-benchmark "0.1.0-SNAPSHOT"
  :description "Typed Clojure benchmark"
  :dependencies [[org.clojure/clojure "1.11.1"]
                 [org.typedclojure/typed.clj.runtime "1.2.0"]]
  :profiles {:dev {:dependencies [[org.typedclojure/typed.clj.checker "1.2.0"]
                                  [nrepl/nrepl "1.0.0"]]}}
  :plugins [[lein-exec "0.3.7"]]
  :main ^:skip-aot typed-clojure.main
  :target-path "target/%s"
  :source-paths ["src"]
  :test-paths ["test"]
  :repl-options {:init-ns typed-clojure.main})