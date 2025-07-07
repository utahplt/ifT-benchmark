(defproject org.my-domain/my-project "0.1.0-SNAPSHOT"
  :dependencies [[org.clojure/clojure "1.11.1"]
                 [org.typedclojure/typed.clj.runtime "1.1.5"]]
  :profiles {:dev {:dependencies [[org.typedclojure/typed.clj.checker "1.1.5"]]}
             :uberjar {:aot :all}}
  :main ^:skip-aot typed-clojure.main
  :target-path "target/%s"
  :source-paths ["src"]
  :test-paths ["test"]
  :repl-options {:init-ns typed-clojure.main})