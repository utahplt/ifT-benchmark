#lang typed/racket

(require typed/json)

;;; Code:
;; Example filter
;; success
(: filter-success (All (S) (-> (-> Any Boolean : S) (Listof Any) (Listof S))))
(define (filter-success predicate list)
  (if (empty? list)
      empty
      (if (predicate (first list))
          (cons (first list) (filter predicate (rest list)))
          (filter predicate (rest list)))))

;; failure
(: filter-failure (All (S) (-> (-> Any Boolean : S) (Listof Any) (Listof S))))
(define (filter-failure predicate list)
  (if (empty? list)
      empty
      (if (predicate (first list))
          (cons (first list) (filter predicate (rest list)))
          (cons (first list) (filter predicate (rest list))))))

; Not sure about how to annotate type subtraction with Any
;; (: flatten (-> Any (Listof (Refine [result : Any] (! result (Listof Any))))))
;; (define (flatten x)
;;   (cond
;;     [(empty? x) empty]
;;     [(pair? x) (append (flatten (first x)) (flatten (rest x)))]
;;     [else (list x)]))

;; Example flatten
;; success
(: flatten-success (-> (U (Listof (U Number (Pairof Number Number))) (U Number (Pairof Number Number)))  (Listof Number)))
(define (flatten-success x)
  (cond
    [(null? x) '()]
    [(pair? x) (append (flatten-success (car x)) (flatten-success (cdr x)))]
    [else (list x)]))

;; failure
(: flatten-failure (-> (U (Listof (U Number (Pairof Number Number))) (U Number (Pairof Number Number)))  (Listof Number)))
(define (flatten-failure x)
  (cond
    [(null? x) '()]
    [(pair? x) (append (flatten-failure (car x)) (flatten-failure (cdr x)))]
    [else x]))

;; Example tree_node
;; success
(define-type TreeNodeSuccess (Pair Number (Listof TreeNodeSuccess)))

(: TreeNodeSuccess? (-> Any Boolean : TreeNodeSuccess))
(define (TreeNodeSuccess? x)
  (and (pair? x)
          (number? (car x))
          (list? (cdr x))
          (andmap TreeNodeSuccess? (cdr x))
          #true))

;; failure
(define-type TreeNodeFailure (Pair Number (Listof TreeNodeFailure)))

(: TreeNodeFailure? (-> Any Boolean : TreeNodeFailure))
(define (TreeNodeFailure? x)
  (and (pair? x)
       (number? (car x))
       (list? (cdr x))
       #true))

;; Example rainfall
;; success
(define (rainfall-success [weather-reports : (Listof JSExpr)]) : Real
  (define total 0.0)
  (define count 0)
  (for ([day (in-list weather-reports)])
    (when (and (hash? day) (hash-has-key? day "rainfall"))
      (let ([val (hash-ref day "rainfall")])
        (when (and (real? val) (<= 0 val 999))
          (set! total (+ total val))
          (set! count (+ count 1))))))
  (if (> count 0)
      (/ total count)
      0))

;; failure
(define (rainfall-failure [weather-reports : (Listof JSExpr)]) : Real
  (define total 0.0)
  (define count 0)
  (for ([day (in-list weather-reports)])
    (when (and (hash? day) (hash-has-key? day "rainfall"))
      (let ([val (hash-ref day "rainfall")])
        (set! total (+ total val))
        (set! count (+ count 1)))))
  (if (> count 0)
      (/ total count)
      0))
