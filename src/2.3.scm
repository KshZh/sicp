#lang sicp



(define (variable? x) (symbol? x))

(define (same-variable? x y)
  (and (variable? x) (variable? y) (eq? x y))) ; 注意，不应该用(symbol? x)。

(define (sum? x) (and (pair? x) (eq? (car x) '+)))

(define (addend s) (cadr s))

; (define (augend s) (caddr s))
; Exercise 2.57: 题目给出的建议是
; Try to do this by changing only the representation for sums and products, without changing the deriv procedure at all.
; For example, the addend of a sum would be the first term, and the augend would be the sum of the rest of the terms.
(define (augend s)
  (let ((rest (cdr (cdr s))))
    (if (null? (cdr rest))
        (car rest)
        (cons '+ rest))))

(define (product? x) (and (pair? x) (eq? (car x) '*)))

(define (multiplier p) (cadr p))

; (define (multiplicand p) (caddr p))
(define (multiplicand p)
  (let ((rest (cdr (cdr p))))
    (if (null? (cdr rest))
        (car rest)
        (cons '* rest))))

(define (exponentiation? x) (and (pair? x) (eq? (car x) '**)))

(define (base x) (cadr x))

(define (exponent x) (caddr x))

(define (=number? exp num)
  (and (number? exp) (= exp num)))

(define (make-sum a1 a2)
  (cond ((=number? a1 0) a2)
        ((=number? a2 0) a1)
        ((and (number? a1) (number? a2)) (+ a1 a2))
        (else (list '+ a1 a2))))

(define (make-product m1 m2)
  (cond ((or (=number? m1 0) (=number? m2 0)) 0)
        ((=number? m1 1) m2)
        ((=number? m2 1) m1)
        ((and (number? m1) (number? m2)) (* m1 m2))
        (else (list '* m1 m2))))

(define (pow b e)
  (cond ((= e 0) 1)
        ((= e 1) b)
        (* b (pow b (- e 1)))))

(define (make-exponentiation b e)
  (cond ((=number? e 0) 1)
        ((=number? e 1) b)
        ((and (number? b) (number? e)) (pow b e))
        (else (list '** b e))))

(define (deriv exp var)
  (cond ((number? exp) 0) ; dc/dx=0
        ((variable? exp) (if (same-variable? exp var) 1 0)) ; dx/dx=1, dy/dx=0
        ((sum? exp) (make-sum (deriv (addend exp) var)
                              (deriv (augend exp) var))) ; d(u+v)/dx=du/dx+dv/dx
        ((product? exp)
         (make-sum
          (make-product (multiplier exp)
                        (deriv (multiplicand exp) var))
          (make-product (deriv (multiplier exp) var)
                        (multiplicand exp)))) ; d(uv)/dx=u(dv/dx)+v(du/dx)
        ((exponentiation? exp)
         (make-product
          (make-product (exponent exp)
                        (make-exponentiation (base exp) (- (exponent exp) 1)))
          (deriv (base exp) var)))
        (else
         (error "unknown expression type: DERIV" exp))))


(deriv '(+ x 3) 'x)
(deriv '(* x y) 'x)
(deriv '(* (* x y) (+ x 3)) 'x)
(deriv '(** x 3) 'x)
(deriv '(* x y (+ x 3)) 'x) ; 一个思路是把省略的*/+补上去。

; Exercise 2.58: TODO


(define rand-init 0)
(define rand-update +1)
(define rand
  ((lambda (x)
     (lambda ()
       (set!
        x (rand-update x)) x))
   rand-init))
