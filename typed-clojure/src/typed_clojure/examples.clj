(ns typed-clojure.examples
  (:require [typed.clojure :as t])
  (:gen-class))

;;; Code:
;; Example filter
;; success
(t/ann filter-success [(t/Vec t/Any) [t/Any :-> t/Bool] :-> (t/Vec t/Any)])
(defn filter-success [array pred]
  (filterv pred array))

;; failure
(t/ann filter-failure [(t/Vec t/Any) [t/Any :-> t/Bool] :-> (t/Vec t/Num)])
(defn filter-failure [array pred]
  (t/ann-form
    (vec (for [value array]
           (if (pred value)
             value
             "string"))) ; Type error: "string" doesn't match (t/Vec t/Num)
    (t/Vec t/Num)))

;; Example flatten
;; success
(t/defalias IntTree
  (t/U Integer (t/Seqable IntTree)))
(t/defalias IntVector
  (t/Vec Integer))
(t/ann flatten-success [IntTree -> IntVector])
(defn flatten-success [l]
  (if (sequential? l)
    (if (empty? l)
      (t/ann-form [] IntVector)
      (let [first-part (flatten-success (first l))
            rest-parts (flatten-success (next l))]
        (t/ann-form (into first-part rest-parts) IntVector)))
    (do
      (assert (and (integer? l) (instance? Integer l)) "Expected an Integer in non-sequential case")
      (t/ann-form [(t/ann-form l Integer)] IntVector))))

;; failure
(t/ann flatten-failure [IntTree -> IntVector])
(defn flatten-failure [l]
  (if (sequential? l)
    (if (empty? l)
      (t/ann-form [] IntVector)
      (let [first-part (t/ann-form (flatten-failure (first l)) IntVector)
            rest-parts (t/ann-form (flatten-failure (next l)) IntVector)]
        (t/ann-form (into first-part rest-parts) IntVector)))
    (t/ann-form l Integer))) ; Expected error: Expected IntVector but found Integer

;; Example tree_node
;; success
(t/defalias TreeNode
  (t/HVec [t/Num (t/Seqable TreeNode)]))
(t/ann tree-node? (t/Pred TreeNode))
(defn tree-node? [node]
  (if (not (and (vector? node) (= (count node) 2)))
    false
    (let [[fst snd] node]
      (if (not (number? fst))
        false
        (if (not (sequential? snd))
          false
          (every? tree-node? snd))))))

;; failure
(t/defalias TreeNode
  (t/HVec [t/Num (t/Seqable TreeNode)]))
(t/ann tree-node? (t/Pred TreeNode))
(defn tree-node? [node]
  (if (not (and (vector? node) (= (count node) 2)))
    false
    (let [[fst snd] node]
      (if (not (number? fst))
        false
        (if (not (sequential? snd))
          false
          true)))))

;; Example rainfall
;; success
(t/defalias DayReport
  (t/Map t/Keyword (t/U nil Double)))
(t/defalias WeatherReport
  (t/Seqable DayReport))
(t/defalias ValidRainfall
  (t/U nil Double))
(t/defalias RainfallResult Double)
(t/ann rainfall-success [WeatherReport -> RainfallResult])
(defn rainfall-success [weather-reports]
  (t/loop [reports :- WeatherReport, weather-reports
           total   :- Double, 0.0
           count   :- Long, (t/ann-form 0 Long)]
    (if (empty? reports)
      (if (> count 0)
        (double (/ total count))
        0.0)
      (let [day (first reports)]
        (if (and (map? day) (not (nil? day)))
          (let [val (t/ann-form (get day :rainfall) (t/U nil Double))]
            (if (and val (double? val))
              (let [val-d (t/ann-form val Double)]
                (if (<= 0.0 val-d 999.0)
                  (recur (rest reports)
                         (+ total val-d)
                         (t/ann-form (inc count) Long))
                  (recur (rest reports) total count)))
              (recur (rest reports) total count)))
          (recur (rest reports) total count))))))

;; failure
(t/defalias DayReport
  (t/Map t/Keyword (t/U nil Double)))
(t/defalias WeatherReport
  (t/Seqable DayReport))
(t/defalias RainfallResult Double)
(t/ann rainfall-failure [WeatherReport -> RainfallResult])
(defn rainfall-failure [weather-reports]
  (t/loop [reports :- WeatherReport, weather-reports
           total   :- Double, 0.0
           count   :- Long, (t/ann-form 0 Long)]
    (if (empty? reports)
      (if (> count 0)
        (double (/ total count))
        0.0)
      (let [day (first reports)]
        (if (and (map? day) (not (nil? day)))
          (let [val (t/ann-form (get day :rainfall) String)]
            (if (not (nil? val))
              (recur (rest reports)
                     (t/ann-form (+ total val) Double) ; Type error: Adding String to Double
                     (t/ann-form (inc count) Long))
              (recur (rest reports) total count)))
          (recur (rest reports) total count))))))
