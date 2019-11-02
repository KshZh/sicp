#lang sicp



; 如果没有数据抽象：
(define (add-numerator n1 n2)
  (+ n1 n2))
(define (add-denominator d1 d2)
  (+ d1 d2))

(define (gcd a b)
  (if (= b 0) ; 当b或r为0时返回a。
      a
      (gcd b (remainder a b))))

; (define (make-rat n d) (cons n d))
; (define (make-rat n d)
;   (let ((g (abs (gcd n d))))
;     (cons (/ n g) (/ d g)))) ; 也可以在selector中进行reduce。
; (define (make-rat n d)
;   (let ((g (abs (gcd n d))))
;     (cond ((and (< n 0) (< d 0)) (cons (/ (- n) g) (/ (- d) g)))
;           ((and (> n 0) (< d 0)) (cons (/ (- n) g) (/ (- d) g)))
;           (else (cons (/ n g) (/ d g))))))
; 更简洁的实现，利用不论是题目中描述的哪种情况，共同点都是分母最终都为正，所以只要分母为负，就让分子分母同除一个负数，否则，同除一个正数。
(define (make-rat n d)
  (let ((g ((if (< d 0) - +) (abs (gcd n d)))))
    (cons (/ n g) (/ d g))))
(define (numer x) (car x))
(define (denom x) (cdr x))

; (define make-rat cons)
; (define numer car)
; (define denom cdr)

(define (add-rat x y)
  (make-rat (+ (* (numer x) (denom y))
               (* (numer y) (denom x)))
            (* (denom x) (denom y))))
(define (sub-rat x y)
  (make-rat (- (* (numer x) (denom y))
               (* (numer y) (denom x)))
            (* (denom x) (denom y))))
(define (mul-rat x y)
  (make-rat (* (numer x) (numer y))
            (* (denom x) (denom y))))
(define (div-rat x y)
  (make-rat (* (numer x) (denom y))
            (* (denom x) (numer y))))
(define (equal-rat? x y)
  (= (* (numer x) (denom y))
     (* (numer y) (denom x))))

(define (print-rat x)
  (newline)
  (display (numer x))
  (display "/")
  (display (denom x)))

(define one-third (make-rat 1 3))
(define one-half (make-rat 1 6))
(print-rat (add-rat one-third one-half)) ; 1/2

(print-rat (make-rat 6 9)) ; 2/3 
(print-rat (make-rat -6 9)) ; -2/3 
(print-rat (make-rat 6 -9)) ; -2/3 
(print-rat (make-rat -6 -9)) ; 2/3
(print-rat (make-rat 1 -2)) ; -1/2
(print-rat (make-rat 6 -9)) ; -2/3

; Exercise 2.17:
(define (last-pair lst)
  (if (null? (cdr lst))
      (car lst)
      (last-pair (cdr lst))))

(last-pair (list 23 72 149 34))


; Exercise 2.18: 用递归过程不好做，考虑迭代过程。
(define (reverse1 lst)
  (cond ((null? lst) nil)
        ((null? (cdr lst)) (cons (car lst) nil))
        (else (cons (reverse1 (cdr lst)) (car lst)))))

(reverse1 (list 1 4 9 16 25))

(define (reverse2 lst)
  (define (iter lst result)
    (if (null? lst)
        result
        (iter (cdr lst) (cons (car lst) result))))
  (iter lst nil))

(reverse2 (list 1 4 9 16 25))

; Exercise 2.19:
; For the last part of the exercise. The order of the coins does not affect the result. **Becuase the procedure computes all possible combinations.** But it does affect the speed of the computation. If you start with the lower valued coins, it'll take much longer.
(define (no-more? lst) (null? lst))
(define (except-first-denomination lst) (cdr lst))
(define (first-denomination lst) (car lst))

(define (cc amount coin-values)
  (cond ((= amount 0) 1) ; 恰好零钱换到0，即这是一条有效的路径，即这是一种有效的兑换零钱的方式，故返回1。
        ((or (< amount 0) (no-more? coin-values)) 0)
        (else
         (+ (cc amount
                (except-first-denomination
                 coin-values))
            (cc (- amount
                   (first-denomination
                    coin-values))
                coin-values)))))

(define us-coins (list 50 25 10 5 1))
(define uk-coins (list 100 50 20 10 5 2 1 0.5))

(cc 100 us-coins)

(define (timed-cc amount coin-values start-time) 
  (cc amount coin-values) 
  (- (runtime) start-time))
(timed-cc 200 us-coins (runtime))       ;19518
(timed-cc 200 (reverse2 us-coins) (runtime)) ;39055

; Exercise 2.20:
(define (even? x) (= (remainder x 2) 0))

(define (same-parity . lst)
  (define (filter x)
    (if (even? (car lst))
        (even? x)
        (not (even? x))))
  (define (iter lst)
    (cond ((null? lst) nil)
          ((filter (car lst)) (cons (car lst) (iter (cdr lst))))
          (else (iter (cdr lst)))))
  (iter lst))

; 更好的函数签名是：
; (define (same-parity first . rest)

(same-parity 1 2 3 4 5 6 7) ; (1 3 5 7)
(same-parity 2 3 4 5 6 7) ; (2 4 6)

; Exercise 2.23:
(define (for-each proc lst)
  (cond ((null? lst) #t)
        (else (proc (car lst)) (for-each proc (cdr lst)))))

; 返回nil，不关心返回值，返回什么都行。
(for-each (lambda (x)
            (newline)
            (display x))
          (list 57 321 88))

; Exercise 2.24: http://community.schemewiki.org/?sicp-ex-2.24
; 最顶层的list，list指向第一个pair，(car list)指向1，(cdr list)指向下一个pair，(car (cdr list))则指向另一个list。
(define lst (list 1 (list 2 (list 3 4))))
lst ; (1 (2 (3 4)))
(cdr lst) ; ((2 (3 4)))
(car (cdr lst)) ; (2 (3 4))

; Exercise 2.25:
(define lst1 (list 1 3 (list 5 7) 9))
lst1 ; (1 3 (5 7) 9)，将打印形式的list编写成代码，只需在每一个左括号前填一个list。
(define lst2 (list (list 7)))
lst2 ; ((7))
(define lst3 (list 1 (list 2 (list 3 (list 4 (list 5 (list 6 7)))))))
lst3 ; (1 (2 (3 (4 (5 (6 7))))))
(car (cdr (car (cdr (cdr lst1)))))
(car (car lst2))
(car (cdr
      (car (cdr
            (car (cdr
                  (car (cdr
                        (car (cdr
                              (car (cdr lst3))))))))))))

; Exercise 2.26:
(define x (list 1 2 3))
(define y (list 4 5 6))
(append x y) ; (1 2 3 4 5 6)
(cons x y) ; ((1 2 3) 4 5 6)
(list x y) ; ((1 2 3) (4 5 6))
; cons创建一个pair，(car pair)指向第一个实参对象，(cdr pair)指向第二个实参对象。
; (list 1 2 3 4)等价于(cons 1 (cons 2 (cons 3 (cons 4 nil))))。
; pair是pair，list是list，后者是一系列pair的集合，最后的一个pair的cdr指向nil。
(cons 1 (cons 2 (cons 3 (cons 4 nil)))) ; (1 2 3 4)，是list。
(list? (cons 1 (cons 2 (cons 3 (cons 4 nil))))) ; #t
(cons 1 (cons 2 (cons 3 4))) ; (1 2 3 . 4)，不是list。
(pair? (cons 1 (cons 2 (cons 3 4)))) ; #t
(list? (cons 1 (cons 2 (cons 3 4)))) ; #f

; Exercise 2.27:
; http://community.schemewiki.org/?sicp-ex-2.27
(define (reverse lst)
  (define (iter lst result)
    (if (null? lst)
        result
        (iter (cdr lst) (cons (car lst) result))))
  (iter lst nil))

(define (deep-reverse lst)
  (define (iter lst result)
    (if (null? lst)
        result
        (iter (cdr lst) (cons (if (list? (car lst))
                                  (iter (car lst) nil)
                                  (car lst))
                              result))))
  (iter lst nil))

(define x00 (list (list 1 2) (list 3 4)))
x00 ; ((1 2) (3 4))
(reverse x00) ; ((3 4) (1 2))
(deep-reverse x00) ; ((4 3) (2 1))

; Exercise 2.28:
(define (fringe tree)
  )

(define x (list (list 1 2) (list 3 4)))
(fringe x)
(1 2 3 4)
(fringe (list x x))
(1 2 3 4 1 2 3 4)