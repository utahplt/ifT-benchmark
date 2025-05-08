#lang typed/racket

;;; Code:
;; Example positive
;; success
(define (positive-success-f [x : Any]) : Any
  (if (string? x)
      (string-length x)
      x))

;; failure
(define (positive-failure-f [x : Any]) : Any
  (if (string? x)
      (+ 1 x)
      x))


;; Example negative
;; success
(define (negative-success-f [x : (U String Number)]) : Number
  (if (string? x)
      (string-length x)
      (+ 1 x)))

;; failure
(define (negative-failure-f [x : (U String Number Boolean)]) : Number
  (if (string? x)
      (string-length x)
      (+ 1 x)))

;; Example connectives
;; success
(define (connectives-success-f [x : (U String Number)]) : Number
  (if (not (number? x))
      (string-length x)
      0))

(define (connectives-success-g [x : Any]) : Number
  (if (or (string? x) (number? x))
      (connectives-success-f x)
      0))

(define (connectives-success-h [x : (U String Number Boolean)]) : Number
  (if (and (not (boolean? x)) (not (number? x)))
      (string-length x)
      0))

;; failure
(define (connectives-failure-f [x : (U String Number)]) : Number
  (if (not (number? x))
      (+ 1 x)
      0))

(define (connectives-failure-g [x : Any]) : Number
  (if (or (string? x) (number? x))
      (+ 1 x)
      0))

(define (connectives-failure-h [x : (U String Number Boolean)]) : Number
  (if (and (not (boolean? x)) (not (number? x)))
      (+ 1 x)
      0))

;; Example nesting_body
;; success
(define (nesting-body-success-f [x : (U String Number Boolean)]) : Number
  (if (not (string? x))
      (if (not (boolean? x))
          (+ 1 x)
          0)
      0))

;; failure
(define (nesting-body-failure-f [x : (U String Number Boolean)]) : Number
  (if (or (string? x) (number? x))
      (if (or (number? x) (boolean? x))
          (string-length x)
          0)
      0))

;; Example struct_fields
;; success
(struct StructFieldsSuccessApple ([a : Any]))

(define (struct-fields-success-f [x : StructFieldsSuccessApple]) : Number
  (if (number? (StructFieldsSuccessApple-a x))
      (StructFieldsSuccessApple-a x)
      0))

;; failure
(struct StructFieldsFailureApple ([a : Any]))

(define (struct-fields-failure-f [x : StructFieldsFailureApple]) : Number
  (if (string? (StructFieldsFailureApple-a x))
      (StructFieldsFailureApple-a x)
      0))

;; Example tuple_elements
;; success
(define (tuple-elements-success-f [x : (Pairof Any Any)]) : Number
  (if (number? (car x))
      (car x)
      0))

;; failure
(define (tuple-elements-failure-f [x : (Pairof Any Any)]) : Number
  (if (number? (car x))
      (+ (car x) (cdr x))
      0))

;; Example tuple_length
;; success
(define (tuple-length-success-f [x : (U (List Number Number) (List String String String))]) : Number
  (if (= 2 (length x))
      (+ (car x) (cadr x))
      (string-length (car x))))

;; failure
(define (tuple-length-failure-f [x : (U (List Number Number) (List String String String))]) : Number
  (if (= 2 (length x))
      (+ (car x) (cadr x))
      (+ (car x) (cadr x))))

;; Example alias
;; success
(define (alias-success-f [x : Any]) : Any
  (let ([y (string? x)])
    (if y
        (string-length x)
        x)))

;; failure
(define (alias-failure-f [x : Any]) : Any
  (let ([y (string? x)])
    (if y
        (+ 1 x)
        x)))

(define (alias-failure-g [x : Any]) : Any
  (let ([y (box (string? x))])
    (set-box! y #t)
    (if (unbox y)
        (string-length x)
        x)))

;; Example nesting_condition
;; success
(define (nesting-condition-success-f [x : Any] [y : Any]) : Number
  (if (if (number? x)
          (string? y)
          #f)
      (+ x (string-length y))
      0))

;; failure
(define (nesting-condition-failure-f [x : Any] [y : Any]) : Number
  (if (if (number? x)
          (string? y)
          (string? y))
      (+ x (string-length y))
      0))

;; Example merge_with_union
;; success
(define (merge-with-union-success-f [x : Any]) : (U String Number)
  (let ([y (cond
             [(string? x) (string-append x "hello")]
             [(number? x) (+ x 1)]
             [else 0])])
    y))

;; failure
(define (merge-with-union-failure-f [x : Any]) : (U String Number)
  (let ([y (cond
             [(string? x) (string-append x "hello")]
             [(number? x) (+ x 1)]
             [else 0])])
    (+ 1 y)))

;; Example predicate_2way
;; success
(: predicate-2way-success-f (-> (U String Number) Boolean : String))
(define (predicate-2way-success-f x)
  (string? x))

(define (predicate-2way-success-g [x : (U String Number)]) : Number
  (if (predicate-2way-success-f x)
      (string-length x)
      x))

;; failure
(: predicate-2way-failure-f (-> (U String Number) Boolean : String))
(define (predicate-2way-failure-f x)
  (string? x))

(define (predicate-2way-failure-g [x : (U String Number)]) : Number
  (if (predicate-2way-failure-f x)
      (+ 1 x)
      x))

;; Example predicate_1way
;; success
(: predicate-1way-success-f (-> (U String Integer) Boolean : #:+ Integer))
(define (predicate-1way-success-f x)
  (and (number? x) (> x 0)))

(define (predicate-1way-success-g [x : (U String Integer)]) : Integer
  (if (predicate-1way-success-f x)
      (+ 1 x)
      0))

;; failure
(: predicate-1way-failure-f (-> (U String Integer) Boolean : #:+ Integer))
(define (predicate-1way-failure-f x)
  (and (number? x) (> x 0)))

(define (predicate-1way-failure-g [x : (U String Integer)]) : Integer
  (if (predicate-1way-failure-f x)
      (+ 1 x)
      (string-length x)))

;; Example predicate_checked
;; success
(: predicate-checked-success-f (-> (U String Number Boolean) Boolean : String))
(define (predicate-checked-success-f x)
  (string? x))

(: predicate-checked-success-g (-> (U String Number Boolean) Boolean : (U Number Boolean)))
(define (predicate-checked-success-g x)
  (not (predicate-checked-success-f x)))

;; failure
(: predicate-checked-failure-f (-> (U String Number Boolean) Boolean : String))
(define (predicate-checked-failure-f x)
  (or (string? x) (number? x)))

(: predicate-checked-failure-g (-> (U String Number Boolean) Boolean : (U Number Boolean)))
(define (predicate-checked-failure-g x)
  (number? x))

;;; End
