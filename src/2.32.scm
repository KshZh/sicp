#lang sicp

(define (stream-car stream) (car stream))
(define (stream-cdr stream) (force (cdr stream)))

(define (stream-enumerate-interval low high)
  (if (> low high)
      the-empty-stream
      (cons-stream
       low
       (stream-enumerate-interval (+ low 1) high))))

(define (stream-filter pred stream)
  (cond ((stream-null? stream) the-empty-stream)
        ((pred (stream-car stream))
         (cons-stream (stream-car stream)
                      (stream-filter
                       pred
                       (stream-cdr stream))))
        (else (stream-filter pred (stream-cdr stream)))))

(stream-car
 (stream-cdr
  (stream-filter even?
                 (stream-enumerate-interval
                  10000 1000000))))

; Exercise 3.50:
(define (stream-map proc . argstreams)
  (if (stream-null? (car argstreams)) ; 这里用car，因为可变参数列表就是一个list，其中每个pair的car指向一个参数，这里是指向一个stream。
      the-empty-stream
      (cons-stream
       (apply proc (map stream-car argstreams))
       (apply stream-map
              (cons proc (map stream-cdr argstreams))))))

; (apply proc (map (lambda (argstream) (stream-car argstream)) argstreams)) ; 无需这么写，因为它们都接收一个参数，且函数体无需任何别的处理。


; Exercise 3.51:
(define (stream-ref stream n)
  (if (= n 0)
      (stream-car stream)
      (stream-ref (stream-cdr stream) (- n 1))))

(define (display-line x) (display x) (newline))

(define (show x)
  (display-line x)
  x) ; show除了打印，相当于一个identity。

; x是一个stream。
; 对该表达式求值会打印0。
(define x
  (stream-map show
              (stream-enumerate-interval 0 10)))

x ; (0 . #<promise>)

(stream-ref x 5) ; 打印1-5，并返回5。
(stream-ref x 7) ; 打印6, 7，并返回7。

; Exercise 3.52:
(define (display-stream s)
  (stream-for-each display-line s))
(define (stream-for-each proc s)
  (if (stream-null? s)
      'done
      (begin (proc (stream-car s))
             (stream-for-each proc (stream-cdr s)))))

(define sum 0)
(define (accum x) (set! sum (+ x sum)) sum) ; 注意这里返回的是sum而不是x。
; seq = [1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105, 120, 136, 153, ...]
(define seq
  (stream-map accum
              (stream-enumerate-interval 1 20)))
seq ; (1 . #<promise>)
sum ; 1

; y = [6, 10, 28, 36, 66, 78, 120, 136, ...]
(define y (stream-filter even? seq))
y ; (6 . #<promise>)
sum ; 6

(define z
  (stream-filter (lambda (x) (= (remainder x 5) 0))
                 seq))
z ; (10 . #<promise>)
sum ; 10
(stream-ref y 7) ; 136，下标从1开始。
sum ; 136
(display-stream z) ; 打印z，返回done。
sum ; 210

; 可以看到，上面反复对seq的各个promise求值，如果没有缓存计算结果，在这里是指向新pair的指针的话，就重复计算了。


(define (integers-starting-from n)
  (cons-stream n (integers-starting-from (+ n 1))))
(define integers (integers-starting-from 1))

(define (divisible? x y) (= (remainder x y) 0))
(define no-sevens
  (stream-filter (lambda (x) (not (divisible? x 7)))
                 integers))
(stream-ref no-sevens 100) ; 117

; sieve of Eratosthenes. We start with the integers beginning with 2,
; which is the first prime. To get the rest of the primes,
; we start by filtering the multiples of 2 from the rest of the integers.
; This leaves a stream beginning with 3, which is the next prime.
; Now we filter the multiples of 3 from the rest of this stream.
; This leaves a stream beginning with 5, which is the next prime, and so on.
(define (sieve stream)
  (cons-stream
   (stream-car stream)
   (sieve (stream-filter
           (lambda (x)
             (not (divisible? x (stream-car stream))))
           (stream-cdr stream)))))
(define primes (sieve (integers-starting-from 2)))

(stream-ref primes 50) ; 233




