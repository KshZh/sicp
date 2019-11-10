#lang sicp

(define (square x) (* x x))
(define (odd? x) (= (remainder x 2) 1))

; primitive map
; (define (map p sequence)
;   (accumulate (lambda (x y) (cons (p x) y)) nil sequence))
(define (append seq1 seq2)
  (accumulate cons seq2 seq1))
(define (length sequence)
  (accumulate (lambda (x y) (+ 1 y)) 0 sequence))



(define (filter predicate sequence)
  (cond ((null? sequence) nil)
        ((predicate (car sequence))
         (cons (car sequence)
               (filter predicate (cdr sequence))))
        (else (filter predicate (cdr sequence)))))
(filter odd? (list 1 2 3 4 5))

(define (accumulate op initial sequence)
  (if (null? sequence)
      initial
      (op (car sequence)
          (accumulate op initial (cdr sequence)))))
(accumulate + 0 (list 1 2 3 4 5))
(accumulate * 1 (list 1 2 3 4 5))
(accumulate cons nil (list 1 2 3 4 5))

(define (enumerate-interval low high)
  (if (> low high)
      nil
      (cons low (enumerate-interval (+ low 1) high))))
(enumerate-interval 2 7)

(define (enumerate-tree tree)
  (cond ((null? tree) nil)
        ((not (pair? tree)) (list tree))
        (else (append (enumerate-tree (car tree)) ; 注意这里用append，和cons不同，append会把多层的list压平。
                      (enumerate-tree (cdr tree))))))
(enumerate-tree (list 1 (list 2 (list 3 4)) 5)) ; (1 2 3 4 5)

(length '(1 2 3 4 5))
(append '(1 2 3) '(34))
(map square (list 1 2 3 4 5))

(define (horner-eval x coefficient-sequence)
  (accumulate (lambda (this-coeff higher-terms) (+ this-coeff (* x higher-terms)))
              0
              coefficient-sequence))
; 1+3x+5x^3+x^5 at x=2
(horner-eval 2 (list 1 3 0 5 0 1)) ; 79

(define (count-leaves1 t)
  (accumulate + 0 (map (lambda (t) 1) (enumerate-tree t))))
(define (count-leaves2 t)
  (accumulate + 0 (map (lambda (t) (if (not (pair? t))
                                       1
                                       (count-leaves2 t))) t)))
(count-leaves1 (list (list 1 2) 3 (list 6 4)))
(count-leaves2 (list (list 1 2) 3 (list 6 4)))

(define (accumulate-n op init seqs)
  (if (null? (car seqs))
      nil
      (cons (accumulate op init (map (lambda (s) (car s)) seqs))
            (accumulate-n op init (map (lambda (s) (cdr s)) seqs)))))
(accumulate-n + 0 (list (list 1 2 3) (list 4 5 6) (list 7 8 9) (list 10 11 12)))

(define (dot-product v w)
  (accumulate + 0 (map * v w))) ; 这里用的是内置的map。

(define (matrix-*-vector m v) ; 左边的矩阵的列的线性组合。
  (map (lambda (row-vector) (dot-product row-vector v)) m))
(define m '((1 2 3 4) (4 5 6 6) (6 7 8 9)))
(define v '(1 1 1 1)) ; 列向量v。
(matrix-*-vector m v) ; (10 21 30)

(define (transpose mat)
  (accumulate-n cons nil mat))
(transpose m) ; ((1 4 6) (2 5 7) (3 6 8) (4 6 9))



(define (flatmap proc seq)
  (accumulate append nil (map proc seq)))

(define (permutations s)
  (if (null? s) ; empty set?
      (list nil) ; sequence containing empty set
      (flatmap (lambda (x)
                 (map (lambda (p) (cons x p)) ; map会将list中的元素p映射为(cons x p)。
                      (permutations (remove x s))))
               s)))

(define (remove item seq)
  (filter (lambda (x) (not (= item x))) seq))

(define empty-board nil)

(define (adjoin-position row col seq)
  (append (list row) seq))

(define (safe? k positions) ; 第k列。
  (define row-of-k (car positions))
  (define (iter cur-col positions)
    (let ((distance (- cur-col 1)))
      (cond ((null? positions) #t)
            ((= row-of-k (car positions)) #f)
            ((or (= row-of-k (+ (car positions) distance))
                 (= row-of-k (- (car positions) distance)))
             #f)
            (else (iter (+ cur-col 1) (cdr positions))))))
  (iter 2 (cdr positions)))

(define (queens board-size)
  (define (queen-cols k)
    (if (= k 0)
        (list empty-board)
        (filter
         (lambda (positions) (safe? k positions))
         (flatmap
          (lambda (rest-of-queens)
            (map (lambda (new-row)
                   (adjoin-position
                    new-row k rest-of-queens))
                 (enumerate-interval 1 board-size))) ; 注意map的第二个参数是一个list，也就是flatmap把rest-of-queens映射为一个list。
          (queen-cols (- k 1))))))
  (queen-cols board-size))

; (queens 8)

(define (get-triples n)
  (flatmap
   (lambda (i)
     (flatmap
      (lambda (j)
        (map
         (lambda (k) (list i j k))
         (enumerate-interval (+ j 1) n)))
      (enumerate-interval (+ i 1) n)))
   (enumerate-interval 1 n)))

; (get-triples 4)

(define (sum seq)
  (accumulate + 0 seq))

(define (s-triple n s)
  (filter (lambda (triple) (= (sum triple) s))
          (get-triples n)))

(s-triple 8 19)

; Exercise 2.54:
(define (equal? l1 l2)
  (cond ((and (null? l1) (null? l2)) #t)
        ((or (null? l1) (null? l2)) #f)
        ((eq? (car l1) (car l2)) (equal? (cdr l1) (cdr l2)))
        ((and (pair? (car l1)) (pair? (car l2))) (and (equal? (car l1) (car l2))
                                                      (equal? (cdr l1) (cdr l2))))
        ((or (pair? (car l1)) (pair? (car l2))) #f)
        ((= (car l1) (car l2)) #t)
        (else #f)))

(equal? '(this is a list) '(this is a list)) ; #t
(equal? '(this is a list) '(this (is a) list)) ; #f
(equal? '(this (is 1) 7) '(this (is 1) 7)) ; #t

; Exercise 2.55: TODO
(car ''abracadabra) ; quote


