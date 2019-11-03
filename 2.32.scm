#lang sicp






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



