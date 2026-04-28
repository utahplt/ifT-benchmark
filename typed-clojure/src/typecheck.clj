(ns typed-clojure.test
  (:require [typed.clojure :as t]))

(def function-names
  '[positive-success-f positive-failure-f
    negative-success-f negative-failure-f
    connectives-success-f connectives-success-g connectives-success-h
    connectives-failure-f connectives-failure-g connectives-failure-h
    nesting-body-success-f nesting-body-failure-f
    struct-fields-success-f struct-fields-failure-f
    tuple-elements-success-f tuple-elements-failure-f
    tuple-length-success-f tuple-length-failure-f
    alias-success-f alias-failure-f alias-failure-g
    nesting-condition-success-f nesting-condition-failure-f
    merge-with-union-success-f merge-with-union-failure-f
    predicate-2way-success-f predicate-2way-success-g
    predicate-2way-failure-f predicate-2way-failure-g
    predicate-1way-success-f predicate-1way-success-g
    predicate-1way-failure-f predicate-1way-failure-g
    predicate-checked-success-f predicate-checked-success-g
    predicate-checked-failure-f predicate-checked-failure-g])

(doseq [f function-names]
  (try
    (let [var-sym (symbol "typed-clojure.main" (str f))
          var-ref (resolve var-sym)]
      (if var-ref
        (do
          (t/cf var-ref)
          (println (str "Function " f " passed type checking")))
        (println (str "Function " f " failed: Could not resolve var " var-sym))))
    (catch Exception e
      (println (str "Function " f " failed: " (.getMessage e))))))
(require '[typed-clojure.main :reload :force])
(t/check-ns-clj 'typed-clojure.main :verbose-types true :verbose-forms true)
(load-file "src/typed_clojure/test.clj") ;; TODO
