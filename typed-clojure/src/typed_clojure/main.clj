(ns typed-clojure.main
  (:require [typed.clojure :as t])
  (:gen-class))

;;; Code:
;; Example positive
;; success
(t/ann positive-success-f [t/Any :-> t/Any])
(defn positive-success-f [x]
  (if (string? x)
    (count x)
    x))

;; failure
(t/ann positive-failure-f [t/Any :-> t/Any])
(defn positive-failure-f [x]
  (if (string? x)
    (t/ann-form (.isNaN x) t/Num) ; Type error: strings don't have .isNaN
    x))

;; Example negative
;; success
(t/ann negative-success-f [(t/U t/Str t/Num) :-> t/Num])
(defn negative-success-f [x]
  (if (string? x)
    (count x)
    (+ x 1)))

;; failure
(t/ann negative-failure-f [(t/U t/Str t/Num t/Bool) :-> t/Num])
(defn negative-failure-f [x]
  (if (string? x)
    (count x)
    (t/ann-form (+ x 1) t/Num))) ; Type error: x could be boolean

;; Example connectives
;; success
(t/ann connectives-success-f [(t/U t/Str t/Num) :-> t/Num])
(defn connectives-success-f [x]
  (if (not (number? x))
    (count x)
    0))

(t/ann connectives-success-g [t/Any :-> t/Num])
(defn connectives-success-g [x]
  (if (or (string? x) (number? x))
    (connectives-success-f x)
    0))

(t/ann connectives-success-h [(t/U t/Str t/Num t/Bool) :-> t/Num])
(defn connectives-success-h [x]
  (if (and (not (boolean? x)) (not (number? x)))
    (count x)
    0))

;; failure
(t/ann connectives-failure-f [(t/U t/Str t/Num) :-> t/Num])
(defn connectives-failure-f [x]
  (if (not (number? x))
    (t/ann-form (+ x 1) t/Num) ; Type error: x could be string
    0))

(t/ann connectives-failure-g [t/Any :-> t/Num])
(defn connectives-failure-g [x]
  (if (or (string? x) (number? x))
    (t/ann-form (+ x 1) t/Num) ; Type error: x could be string
    0))

(t/ann connectives-failure-h [(t/U t/Str t/Num t/Bool) :-> t/Num])
(defn connectives-failure-h [x]
  (if (and (not (boolean? x)) (not (number? x)))
    (t/ann-form (+ x 1) t/Num) ; Type error: x is string
    0))

;; Example nesting_body
;; success
(t/ann nesting-body-success-f [(t/U t/Str t/Num t/Bool) :-> t/Num])
(defn nesting-body-success-f [x]
  (if (not (string? x))
    (if (not (boolean? x))
      (+ x 1)
      0)
    0))

;; failure
(t/ann nesting-body-failure-f [(t/U t/Str t/Num t/Bool) :-> t/Num])
(defn nesting-body-failure-f [x]
  (if (or (string? x) (number? x))
    (if (or (number? x) (boolean? x))
      (t/ann-form (count x) t/Num) ; Type error: x could be number
      0)
    0))

;; Example struct_fields
;; success
(t/ann struct-fields-success-f [(t/Map t/Keyword t/Any) :-> t/Num])
(defn struct-fields-success-f [x]
  (if (number? (:a x))
    (:a x)
    0))

;; failure
(t/ann struct-fields-failure-f [(t/Map t/Keyword t/Any) :-> t/Num])
(defn struct-fields-failure-f [x]
  (if (string? (:a x))
    (t/ann-form (:a x) t/Num) ; Type error: (:a x) is string
    0))

;; Example tuple_elements
;; success
(t/ann tuple-elements-success-f [(t/Vec t/Any) :-> t/Num])
(defn tuple-elements-success-f [x]
  (if (number? (nth x 0))
    (nth x 0)
    0))

;; failure
(t/ann tuple-elements-failure-f [(t/Vec t/Any) :-> t/Num])
(defn tuple-elements-failure-f [x]
  (if (number? (nth x 0))
    (t/ann-form (+ (nth x 0) (nth x 1)) t/Num) ; Type error: (nth x 1) could be non-number
    0))

;; Example tuple_length
;; success
(t/ann tuple-length-success-f [(t/U (t/Vec t/Num) (t/Vec t/Str)) :-> t/Num])
(defn tuple-length-success-f [x]
  (if (= (count x) 2)
    (+ (nth x 0) (nth x 1))
    (count (nth x 0))))

;; failure
(t/ann tuple-length-failure-f [(t/U (t/Vec t/Num) (t/Vec t/Str)) :-> t/Num])
(defn tuple-length-failure-f [x]
  (if (= (count x) 2)
    (+ (nth x 0) (nth x 1))
    (t/ann-form (+ (nth x 0) (nth x 1)) t/Num))) ; Type error: x[0], x[1] could be strings

;; Example alias
;; success
(t/ann alias-success-f [t/Any :-> t/Any])
(defn alias-success-f [x]
  (let [y (string? x)]
    (if y
      (count x)
      x)))

;; failure
(t/ann alias-failure-f [t/Any :-> t/Any])
(defn alias-failure-f [x]
  (let [y (string? x)]
    (if y
      (t/ann-form (.isNaN x) t/Num) ; Type error: strings don't have .isNaN
      x)))

;; failure
(t/ann alias-failure-g [t/Any :-> t/Any])
(defn alias-failure-g [x]
  (let [y true] ; Overwrites type check
    (if y
      (t/ann-form (count x) t/Any) ; Type error: x could be any type
      x)))

;; Example nesting_condition
;; success
(t/ann nesting-condition-success-f [t/Any t/Any :-> t/Num])
(defn nesting-condition-success-f [x y]
  (if (if (number? x) (string? y) false)
    (+ x (count y))
    0))

;; failure
(t/ann nesting-condition-failure-f [t/Any t/Any :-> t/Num])
(defn nesting-condition-failure-f [x y]
  (if (if (number? x) (string? y) (string? y))
    (t/ann-form (+ x (count y)) t/Num) ; Type error: x could be non-number
    0))

;; Example merge_with_union
;; success
(t/ann merge-with-union-success-f [t/Any :-> (t/U t/Str t/Num)])
(defn merge-with-union-success-f [x]
  (cond
    (string? x) (str x "hello")
    (number? x) (+ x 1)
    :else 0))

;; failure
(t/ann merge-with-union-failure-f [t/Any :-> (t/U t/Str t/Num)])
(defn merge-with-union-failure-f [x]
  (let [result (cond
                 (string? x) (str x "hello")
                 (number? x) (+ x 1)
                 :else 0)]
    (t/ann-form (.isNaN result) t/Bool))) ; Type error: result could be string

;; Example predicate_2way
;; success
(t/ann predicate-2way-success-f [(t/U t/Str t/Num) :-> t/Bool])
(defn predicate-2way-success-f [x]
  (string? x))

(t/ann predicate-2way-success-g [(t/U t/Str t/Num) :-> t/Num])
(defn predicate-2way-success-g [x]
  (if (predicate-2way-success-f x)
    (count x)
    x))

;; failure
(t/ann predicate-2way-failure-f [(t/U t/Str t/Num) :-> t/Bool])
(defn predicate-2way-failure-f [x]
  (string? x))

(t/ann predicate-2way-failure-g [(t/U t/Str t/Num) :-> t/Num])
(defn predicate-2way-failure-g [x]
  (if (predicate-2way-failure-f x)
    (t/ann-form (+ x 1) t/Num) ; Type error: x is string
    x))

;; Example predicate_1way
;; success
(t/ann predicate-1way-success-f [(t/U t/Str t/Num) :-> t/Bool])
(defn predicate-1way-success-f [x]
  (and (number? x) (> x 0)))

(t/ann predicate-1way-success-g [(t/U t/Str t/Num) :-> t/Num])
(defn predicate-1way-success-g [x]
  (if (predicate-1way-success-f x)
    (+ x 1)
    0))

;; failure
(t/ann predicate-1way-failure-f [(t/U t/Str t/Num) :-> t/Bool])
(defn predicate-1way-failure-f [x]
  (and (number? x) (> x 0)))

(t/ann predicate-1way-failure-g [(t/U t/Str t/Num) :-> t/Num])
(defn predicate-1way-failure-g [x]
  (if (predicate-1way-failure-f x)
    (+ x 1)
    (t/ann-form (count x) t/Num))) ; Type error: x could be string

;; Example predicate_checked
;; success
(t/ann predicate-checked-success-f [(t/U t/Str t/Num t/Bool) :-> t/Bool])
(defn predicate-checked-success-f [x]
  (string? x))

(t/ann predicate-checked-success-g [(t/U t/Str t/Num t/Bool) :-> t/Bool])
(defn predicate-checked-success-g [x]
  (not (predicate-checked-success-f x)))

;; failure
(t/ann predicate-checked-failure-f [(t/U t/Str t/Num t/Bool) :-> t/Bool])
(defn predicate-checked-failure-f [x]
  (or (string? x) (number? x)))

(t/ann predicate-checked-failure-g [(t/U t/Str t/Num t/Bool) :-> t/Bool])
(defn predicate-checked-failure-g [x]
  (number? x))

(t/ann -main [& t/Str :-> t/Any])
(defn -main
  "Run all success and failure functions."
  [& args]
  (doseq [[name f input] [
                          ["positive-success-f" positive-success-f "hello"]
                          ["positive-failure-f" positive-failure-f "hello"]
                          ["negative-success-f" negative-success-f 5]
                          ["negative-failure-f" negative-failure-f true]
                          ["connectives-success-f" connectives-success-f "test"]
                          ["connectives-success-g" connectives-success-g 10]
                          ["connectives-success-h" connectives-success-h "hi"]
                          ["connectives-failure-f" connectives-failure-f "test"]
                          ["connectives-failure-g" connectives-failure-g "test"]
                          ["connectives-failure-h" connectives-failure-h "hi"]
                          ["nesting-body-success-f" nesting-body-success-f 3]
                          ["nesting-body-failure-f" nesting-body-failure-f 3]
                          ["struct-fields-success-f" struct-fields-success-f {:a 42}]
                          ["struct-fields-failure-f" struct-fields-failure-f {:a "hello"}]
                          ["tuple-elements-success-f" tuple-elements-success-f [1 2]]
                          ["tuple-elements-failure-f" tuple-elements-failure-f [1 "two"]]
                          ["tuple-length-success-f" tuple-length-success-f [1 2]]
                          ["tuple-length-failure-f" tuple-length-failure-f ["a" "b" "c"]]
                          ["alias-success-f" alias-success-f "hello"]
                          ["alias-failure-f" alias-failure-f "hello"]
                          ["alias-failure-g" alias-failure-g 42]
                          ["nesting-condition-success-f" nesting-condition-success-f [5 "test"]]
                          ["nesting-condition-failure-f" nesting-condition-failure-f ["test" "test"]]
                          ["merge-with-union-success-f" merge-with-union-success-f "hello"]
                          ["merge-with-union-failure-f" merge-with-union-failure-f "hello"]
                          ["predicate-2way-success-f" predicate-2way-success-f "test"]
                          ["predicate-2way-success-g" predicate-2way-success-g "test"]
                          ["predicate-2way-failure-f" predicate-2way-failure-f "test"]
                          ["predicate-2way-failure-g" predicate-2way-failure-g "test"]
                          ["predicate-1way-success-f" predicate-1way-success-f 5]
                          ["predicate-1way-success-g" predicate-1way-success-g 5]
                          ["predicate-1way-failure-f" predicate-1way-failure-f "test"]
                          ["predicate-1way-failure-g" predicate-1way-failure-g "test"]
                          ["predicate-checked-success-f" predicate-checked-success-f "test"]
                          ["predicate-checked-success-g" predicate-checked-success-g 10]
                          ["predicate-checked-failure-f" predicate-checked-failure-f "test"]
                          ["predicate-checked-failure-g" predicate-checked-failure-g 10]]]
    (println (str name ":"))
    (try
      (println "  Result:" (if (vector? input) (apply f input) (f input)))
      (catch Exception e
        (println "  Error:" (.getMessage e)))))
  :done)