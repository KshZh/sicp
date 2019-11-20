#lang sicp

; stream是一个pair，car指向已求值的结果，cdr指向promise。

(define (stream-car stream) (car stream))
(define (stream-cdr stream) (force (cdr stream)))

; 错位相加，将stream的当前元素与pre相加。
(define (partial-sums stream)
  (define (helper pre s)
    (if (null? s)
        nil
        (let ((new-pre (+ pre (stream-car s))))
          (cons-stream new-pre (helper new-pre (stream-cdr s))))))
  (helper 0 stream)
)

(define ones (cons-stream 1 ones))

(define (stream-ref stream n)
  (if (= n 0)
      (stream-car stream)
      (stream-ref (stream-cdr stream) (- n 1))))

(define partial-sums-stream (partial-sums ones))
(stream-ref partial-sums-stream 8)