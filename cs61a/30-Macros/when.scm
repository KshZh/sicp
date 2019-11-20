; without quasiquotes
(define-macro (when condition . exprs)
  (list 'if condition (cons 'begin exprs) ''okay)) ; condition是一个未求值的expr/list，exprs是一个未求值的list，每一个pair的car指向一个未求值的实参。

; with quasiquotes
(define-macro (when condition . exprs)
  `(if ,condition ,(cons 'begin exprs) 'okay)) ; 要使用,condition，否则就会产出一个list，其中第二个pair的car指向符号condition，而不是list/expr condition。