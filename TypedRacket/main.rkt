#lang typed/racket

;;; Code:
;; Example 1
(: example-1 (-> Any Number))
(define (example-1 [x : Any])
  (if (number? x)
      (add1 x)
      0))

;; Example 2
(: example-2 (-> (U String Number) Number))
(define (example-2 x)
  (if (number? x)
      (add1 x)
      (string-length x)))

;; Example 3
(: example-3 (-> (Listof Number) Number Number))
(define (example-3 l v)
  (let ([x (member v l)])
    (if x
        (first x)
        (error 'fail))))

;; Example 4
(: example-4 (-> Any Number))
(define (example-4 x)
  (if (or (number? x) (string? x))
      ((lambda ([x : (U String Number)]) : Number
         (if (number? x)
             (add1 x)
             (string-length x))) x)
      0))

;; Example 5
(: example-5 (-> Any Any Number))
(define (example-5 x y)
  (if (and (number? x) (string? y))
      (+ x (string-length y))
      0))

;; Example 6 (fail)
(: example-6 (-> Any Any Number))
(define (example-6 x y)
  (if (and (number? x) (string? y))
      (+ x (string-length y))
      (string-length x)))

;; Example 7
(: example-7 (-> Any Any Number))
(define (example-7 x y)
  (if (if (number? x) (string? y) #f)
      (+ x (string-length y))
      0))

;; Example 8
(: example-8 (-> Any Boolean : (U String Number)))
(define (example-8 x)
  (or (string? x) (number? x)))

(let ([x 1])
  (if (example-8 x)
      ((lambda ([x : (U String Number)]) : Number
         (if (number? x)
             (add1 x)
             (string-length x))) x)
      0))

;; Example 9
(: example-9 (-> Any Number))
(define (example-9 x)
  (if (let ([tmp (number? x)])
        (if tmp tmp (string? x)))
      ((lambda ([x : (U String Number)]) : Number
         (if (number? x)
             (add1 x)
             (string-length x))) x)
      0))

;; Example 10
(: example-10 (-> (Pairof Any Any) Number))
(define (example-10 p)
  (if (number? (car p))
      (add1 (car p))
      7))

;; Example 11
(: example-11 (-> (Pairof Any Any) Number))
(define example-11
  (let ([g (lambda ([x : (Pairof Any Any)]) (car x))])
    (lambda ([p : (Pairof Any Any)])
      (if (and (number? (car p)) (number? (cdr p)))
          (g p)
          0))))

(example-11 '(1 . 2))
(example-11 '('a . 'b))

;; Example 12
(: example-12 (-> (Pairof Any Any) Boolean : (Pairof Number Any)))
(define (example-12 [x : (Pairof Any Any)])
  (number? (car x)))

(example-12 '(1 . 2))
(example-12 '('s . 2))

;; Example 13
(define (example-13-aux-1 [x : Number] [y : String]) : Number
  x)

(: example-13-aux-2 (-> ([x : Number] [y : Number]) Number))
(define (example-13-aux-2 x y) : Number
  y)

(define (example-13 [x : Any] [y : (U Number String)])
  (cond
    [(and (number? x) (string? y)) (example-13-aux-1 x y)]
    [(number? x) (example-13-aux-2 x y)]
    [else 0]))

;; Example 14
(: example-14 (-> (U Number String) (Pairof Any Any) Number))
(define (example-14 input extra)
  (cond
    [(and (number? input) (number? (car extra)))
     (+ input (car extra))]
    [(number? (car extra))
     (+ (string-length input) (car extra))]
    [else 0]))

;;; End
