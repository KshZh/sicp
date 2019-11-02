#lang sicp

(define (abs1 x)
  (cond ((< x 0) (- x))
        ((> x 0) x)
        ((= x 0) 0)))

(define (abs2 x)
  (cond ((< x 0) (- x))
        (else x)))

(define (abs3 x)
  (if (< x 0)
      (- x)
      x))

(abs3 -3)
(abs3 4)


(define (a-plus-abs-b a b)
  ((if (> b 0) + -) a b))


(define (square x)
  (* x x))
(define (average x y)
  (/ (+ x y) 2))
;(define (improve guess x)
;  (average (/ x guess) guess))
(define (improve guess x)
  (/ (+ (/ x (square guess)) (* 2 guess)) 3))
;; Modified version to look at difference between iterations 
(define (good-enough? guess x) 
 (< (abs (- (improve guess x) guess)) 
    (* guess .001)))
(define (sqrt-iter guess x)
  (if (good-enough? guess x)
      guess
      (sqrt-iter (improve guess x) x)))

(define (sqrt x)
  (sqrt-iter 1.0 x)) ; 注意这里要传递1.0而不是1，这样才会将结果显式为小数而不是分数。

(sqrt 8)
(sqrt 9)
(sqrt 2)
(square (sqrt 1000))
(sqrt 0.0001) ; 0.03230844833048122
(sqrt 1000000000000) ; 1000000.0
(square (sqrt 10000000000000)) ; endless loop
; The algorithm gets stuck because (improve guess x) keeps on yielding 4472135.954999579 but (good-enough? guess x) keeps returning #f.




