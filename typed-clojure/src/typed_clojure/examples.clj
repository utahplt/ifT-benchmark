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
(t/ann MaybeNestedListSuccess
       (t/Rec [x (t/U t/Num (t/Vec x))]))
(t/ann flatten-success [MaybeNestedListSuccess :-> (t/Vec t/Num)])
(defn flatten-success [l]
  (if (vector? l)
    (if (empty? l)
      []
      (into (flatten-success (first l))
            (flatten-success (rest l))))
    [l]))

;; failure
(t/ann MaybeNestedListFailure
       (t/Rec [x (t/U t/Num (t/Vec x))]))
(t/ann flatten-failure [MaybeNestedListFailure :-> (t/Vec t/Num)])
(defn flatten-failure [l]
  (if (vector? l)
    (if (empty? l)
      []
      (into (flatten-failure (first l))
            (flatten-failure (rest l))))
    (t/ann-form l (t/Vec t/Num)))) ; Type error: l is t/Num, not (t/Vec t/Num)

;; Example tree_node
;; success
(t/ann TreeNodeSuccess
       (t/Rec [x (t/Map t/Keyword (t/U t/Num (t/Option (t/Vec x))))]))
(t/ann is-tree-node-success [TreeNodeSuccess :-> t/Bool])
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
(t/ann TreeNodeFailure
       (t/Rec [x (t/Map t/Keyword (t/U t/Num (t/Option (t/Vec x))))]))
(t/ann is-tree-node-failure [TreeNodeFailure :-> t/Bool])
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
  (let [valid-reports (filter (fn [day]
                                (and (map? day)
                                     (some? day)
                                     (contains? day :rainfall)))
                              weather-reports)
        total (reduce + 0 (map :rainfall valid-reports)) ; Type error: :rainfall may not be a number
        count (count valid-reports)]
    (if (pos? count)
      (t/ann-form (/ total count) t/Num)
      0)))
