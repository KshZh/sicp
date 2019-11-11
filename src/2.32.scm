#lang sicp

; Exercise 3.1:
(define (make-accumulator sum)
  (lambda (x) (begin (set! sum (+ sum x)) sum)))
(define A (make-accumulator 5))
(A 10)
(A 15)

; Exercise 3.2:
(define (make-monitored f)
  (let ((count 0))
    (lambda (first . rest)
      (if (eq? first 'how-many-calls?)
          count
          (begin (set! count (+ count 1)) (apply f (cons first rest)))))))

(define s (make-monitored sqrt))
(s 100) ; 10
(s 4) ; 2
(s 'how-many-calls?) ; 2

; Exercise 3.3:
(define (make-account balance password)
  (define (withdraw amount)
    (if (>= balance amount)
        (begin (set! balance (- balance amount))
               balance)
        "Insufficient funds"))
  (define (deposit amount)
    (set! balance (+ balance amount))
    balance)
  (define (dispatch pwd m)
    (cond ((not (eq? pwd password)) (lambda (amount) (display "Incorrect password") (newline)))
          ((eq? m 'withdraw) withdraw)
          ((eq? m 'deposit) deposit)
          (else (error "Unknown request: MAKE-ACCOUNT"
                       m))))
  dispatch)

(define acc (make-account 100 'secret-password))
((acc 'secret-password 'withdraw) 40)
((acc 'some-other-password 'deposit) 50)

; Exercise 3.4:
(define (make-account-2 balance password)
  (define consecutive-password-mismatch 0)
  (define (call-the-cops) (lambda (amount) (display "Cops called!") (newline)))
  (define (withdraw amount)
    (if (>= balance amount)
        (begin (set! balance (- balance amount))
               balance)
        "Insufficient funds"))
  (define (deposit amount)
    (set! balance (+ balance amount))
    balance)
  (define (dispatch pwd m)
    (cond ((not (eq? pwd password)) (begin
                                      (set! consecutive-password-mismatch (+ consecutive-password-mismatch 1))
                                      (if (> consecutive-password-mismatch 3) ; 这里方便测试设置为3次。
                                          (call-the-cops)
                                          (lambda (amount) (display "Incorrect password") (newline)))))
          ((eq? m 'withdraw) (begin (set! consecutive-password-mismatch 0) withdraw))
          ((eq? m 'deposit) (begin (set! consecutive-password-mismatch 0) deposit))
          (else (error "Unknown request: MAKE-ACCOUNT"
                       m))))
  dispatch)

(define acc-2 (make-account-2 100 'secret-password))
((acc-2 'some-other-password 'deposit) 50)
((acc-2 'secret-password 'withdraw) 40)
((acc-2 'some-other-password 'deposit) 50)
((acc-2 'some-other-password 'deposit) 50)
((acc-2 'some-other-password 'deposit) 50)
((acc-2 'some-other-password 'deposit) 50)

