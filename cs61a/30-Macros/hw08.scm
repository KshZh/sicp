; Macros

(define-macro (list-of map-expr for var in lst if filter-expr)
  (list 'map
        (list 'lambda (list var) map-expr)
        (list 'filter
              (list 'lambda (list var) filter-expr)
              lst)) 
)

; map-expr和filter-expr是compound expr，用list存储，而且special form define-macro的求值规则不会先对这两个参数求值，所以不用'map-expr，
; 而var就是符号，define-macro也不会先对其求值，所以也不需要'var。