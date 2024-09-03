#lang typed/racket

;; Example 1
(let ([x "str"])
  (if (number? x)
      (add1 x)
      0))

(let ([x 1])
  (if (number? x)
      (add1 x)
      0))

;; Example 2
(: f (-> (U String Number) Number))
(define (f x)
  (if (number? x)
      (add1 x)
      (string-length x)))

;; Example 3
(let ([l '(1 2 3 4)]
      [v 1])
  (let ([x (member v l)])
    (if x
        (first x)
        (error 'fail))))

;; Example 4
(let ([x 1])
  (if (or (number? x) (string? x))
      (f x)
      0))

(let ([x "str"])
  (if (or (number? x) (string? x))
      (f x)
      0))

(let ([x 'sym])
  (if (or (number? x) (string? x))
      (f x)
      0))

;; Example 5
(let ([x 5]
      [y "str"])
  (if (and (number? x) (string? y))
      (+ x (string-length y))
      0))

;; Example 6 (this should fail)
;; (let ([x 5]
;;       [y 6])
;;   (if (and (number? x) (string? y))
;;       (+ x (string-length y))
;;       (string-length x)))

;; and this should pass
(let ([x "str"]
      [y "also str"])
  (if (and (number? x) (string? y))
      (+ x (string-length y))
      (string-length x)))

;; Example 7
(let ([x 5]
      [y "str"])
  (if (if (number? x) (string? y) #f)
      (+ x (string-length y))
      0))

;; Example 8
(: strnum? (-> Any Boolean))
(define (strnum? x)
  (or (string? x) (number? x)))

;; Example 9
(let ([x 5])
  (if (let ([tmp (number? x)])
        (if tmp tmp (string? x)))
      (f x)
      0))

(let ([x "str"])
  (if (let ([tmp (number? x)])
        (if tmp tmp (string? x)))
      (f x)
      0))

;; Example 10
(let ([p '(1 . "str")])
  (if (number? (car p))
      (add1 (car p))
      7))

(let ([p '("str" . 1)])
  (if (number? (car p))
      (add1 (car p))
      7))

;; Example 11
(define example11
  (let ([g (lambda ([x : (Pairof Any Any)]) (car x))])
    (lambda ([p : (Pairof Any Any)])
      (if (and (number? (car p)) (number? (cdr p)))
          (g p)
          'no))))

(example11 '(1 . 2))
(example11 '('a . 'b))

;; Example 12
(define (carnum? [x : (Pairof Any Any)])
  (number? (car x)))

(carnum? '(1 . 2))
(carnum? '('s . 2))

;; Example 13
(let ([x 1]
      [y "str"])
  (cond
    [(and (number? x) (string? y)) 'a]
    [(number? x) 'b]
    [else 'c]))

;; Example 14
(lambda ([input : (U Number String)]
         [extra : (Pairof Any Any)])
  (cond
    [(and (number? input) (number? (car extra)))
     (+ input (car extra))]
    [(number? (car extra))
     (+ (string-length input) (car extra))]
    [else 0]))
