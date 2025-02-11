#lang typed/racket

(: filter (All (S) (-> (-> Any Boolean : S) (Listof Any) (Listof S))))
(define (filter predicate list)
  (if (empty? list)
      empty
      (if (predicate (first list))
          (cons (first list) (filter predicate (rest list)))
          (filter predicate (rest list)))))

; Not sure about how to annotate type subtraction with Any
;; (: flatten (-> Any (Listof (Refine [result : Any] (! result (Listof Any))))))
;; (define (flatten x)
;;   (cond
;;     [(empty? x) empty]
;;     [(pair? x) (append (flatten (first x)) (flatten (rest x)))]
;;     [else (list x)]))

(: flatten (-> (U (Listof (U Number (Pairof Number Number))) (U Number (Pairof Number Number)))  (Listof Number)))
(define (flatten x)
  (cond
    [(null? x) '()]
    [(pair? x) (append (flatten (car x)) (flatten (cdr x)))]
    [else (list x)]))

(define-type TreeNode (Pair Number (Listof TreeNode)))

(: TreeNode? (-> Any Boolean : TreeNode))
(define (TreeNode? x)
     (and (pair? x)
          (number? (car x))
          (list? (cdr x))
          (andmap TreeNode? (cdr x))
          #true))

(require typed/json)

(define (rainfall [weather-reports : (Listof JSExpr)]) : Real
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
