(ns typed-clojure.examples
  (:require [typed.clojure :as t])
  (:gen-class))

;;; Code:
;; Example filter
;; success
(t/ann filter-success
       [(t/Vec t/Any) [t/Any :-> t/Bool] :-> (t/Vec t/Any)])
(defn filter-success [array pred]
  (filterv pred array))

;; failure
(t/ann filter-failure
       [(t/Vec t/Any) [t/Any :-> t/Bool] :-> (t/Vec t/Any)])
(defn filter-failure [array pred]
  (t/ann-form
    (vec (for [value array]
           (if (pred value)
             value
             (t/ann-form value t/Any)))) ; Type error: pushes unfiltered values
    (t/Vec t/Any)))

;; Example flatten
;; success
(t/ann ^:no-check maybe-nested-list-success
       (t/Rec [x (t/U t/Num (t/Vec x))]))
(t/ann flatten-success [maybe-nested-list-success :-> (t/Vec t/Num)])
(defn flatten-success [l]
  (if (vector? l)
    (if (empty? l)
      []
      (into (flatten-success (first l))
            (flatten-success (rest l))))
    [l]))

;; failure
(t/ann ^:no-check maybe-nested-list-failure
       (t/Rec [x (t/U t/Num (t/Vec x))]))
(t/ann flatten-failure [maybe-nested-list-failure :-> (t/Vec t/Num)])
(defn flatten-failure [l]
  (if (vector? l)
    (if (empty? l)
      []
      (into (flatten-failure (first l))
            (flatten-failure (rest l))))
    (t/ann-form l (t/Vec t/Num)))) ; Type error: l is number, not vector

;; Example tree_node
;; success
(t/ann ^:no-check tree-node-success
       (t/Rec [x (t/Map t/Keyword (t/U t/Num (t/Option (t/Vec x))))]))
(t/ann is-tree-node-success [t/Any :-> t/Bool])
(defn is-tree-node-success [node]
  (if (not (and (map? node) (some? node)))
    false
    (if (not (number? (:value node)))
      false
      (if-let [children (:children node)]
        (if (not (vector? children))
          false
          (every? is-tree-node-success children))
        true))))

;; failure
(t/ann ^:no-check tree-node-failure
       (t/Rec [x (t/Map t/Keyword (t/U t/Num (t/Option (t/Vec x))))]))
(t/ann is-tree-node-failure [t/Any :-> t/Bool])
(defn is-tree-node-failure [node]
  (if (not (and (map? node) (some? node)))
    false
    (if (not (number? (:value node)))
      false
      (if-let [children (:children node)]
        (t/ann-form (vector? children) t/Bool) ; Type error: incomplete child check
        true))))

;; Example rainfall
;; success
(t/ann rainfall-success [(t/Vec t/Any) :-> t/Num])
(defn rainfall-success [weather-reports]
  (let [valid-reports (filter (fn [day]
                                (and (map? day)
                                     (some? day)
                                     (contains? day :rainfall)
                                     (number? (:rainfall day))
                                     (<= 0 (:rainfall day) 999)))
                              weather-reports)
        total (reduce + 0 (map :rainfall valid-reports))
        count (count valid-reports)]
    (if (pos? count)
      (/ total count)
      0)))

;; failure
(t/ann rainfall-failure [(t/Vec t/Any) :-> t/Num])
(defn rainfall-failure [weather-reports]
  (let [reports (filter (fn [day]
                          (and (map? day)
                               (some? day)
                               (contains? day :rainfall)))
                        weather-reports)
        total (t/ann-form
                (reduce + 0 (map :rainfall reports))
                t/Num) ; Type error: :rainfall could be non-number
        count (count reports)]
    (if (pos? count)
      (/ total count)
      0)))

(t/ann -main [& t/Str :-> t/Any])
(defn -main
  "Run all success and failure functions."
  [& args]
  (doseq [[name f input] [
                          ["filter-success"
                           #(filter-success %1 %2)
                           [[1 "two" 3] number?]]
                          ["filter-failure"
                           #(filter-failure %1 %2)
                           [[1 "two" 3] number?]]
                          ["flatten-success"
                           flatten-success
                           [1 [2 [3 4]] 5]]
                          ["flatten-failure"
                           flatten-success
                           [1 [2 [3 4]] 5]]
                          ["is-tree-node-success"
                           is-tree-node-success
                           {:value 1 :children [{:value 2} {:value 3}]}]
                          ["is-tree-node-failure"
                           is-tree-node-failure
                           {:value 1 :children [{:value 2} {:value 3}]}]
                          ["rainfall-success"
                           rainfall-success
                           [{:rainfall 10} {:rainfall "invalid"} {:rainfall 20}]]
                          ["rainfall-failure"
                           rainfall-failure
                           [{:rainfall 10} {:rainfall "invalid"} {:rainfall 20}]]]]
    (println (str name ":"))
    (try
      (println "  Result:" (f input))
      (catch Exception e
        (println "  Error:" (.getMessage e)))))
  :done)