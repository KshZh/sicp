### 表达式求值规则

scheme中的符号，可以猜想在scheme解释器中以字符串形式存储的，注意，不要以为我们写的关键字没有用双引号包起来就不可以是字符串了，只是对编程语言的使用者来说不是，但解释器仍然是一个程序，可以以字符串，即ascii序列存储关键字或符号。

scheme解释器对primitive expr的求值规则是：

- the values of numerals are the numbers that they name,
- the values of built-in operators are the machine instruction sequences that carry out the corresponding operations, and
- the values of other names are the objects associated with those names in the environment.（这里的Object可以是过程对象或数据）

```scheme
1 ; 符号1求值为整型1，符号1和整型1的区别，前者是ascii码49，后者是二进制1。
+ ; 全局环境中符号+默认绑定到内置的过程对象+。
; a ; unbound identifier，variable lookup失败。
```

对compound expr的求值规则是：先对操作符和操作数求值，然后将操作数的值应用到操作符的值上去。注意，对操作符也要求值，因为操作符输入时就是一个符号，符号是没法被apply的，只有经过eval，在当前环境找到一个对应的可调用过程对象时，对这个过程对象才可以apply。（special form有自己的求值规则）

```scheme
(define a "a") ; 对符号define求值，得到全局环境中关联的内置的过程对象。由于define是一个special form，所以它不会对操作数求值，而是在当前环境中关联符号a和它的值"a"。
(+ 1 2) ; 对符号+求值，得到全局环境中关联的内置的过程对象，对符号1, 2求值，得到整型1, 2，然后把整型1, 2应用到可调用的过程对象+上去。
; (1 2 3) ; 对符号1求值，得到整型1，整型1不是可调用的过程对象，报错：not a procedure。
(define (square x) (* x x)) ; special form，过程对象define在当前环境中创建一个符号square，关联到一个过程对象上去，该过程对象有两个指针，一个指向代码/指令，一个指向当前环境。
(square 2) ; 同理。
(* 1 (+ 3 4)) ; 对操作符和操作数求值，只不过这里第二个操作数也是一个compound expr，也是按照递归的求值规则求值。
```

可以猜想，scheme解释器读入的compound expr都是以list存储的。而quote的作用就是抑制求值。

```scheme
; (1 2 3) ; scheme解释器读入输入，词法语法分析后用list存储这个compound expr，然后对其求值，导致：application: not a procedure。
'(1 2 3) ; 用quote抑制求值，(1 2 3)就只是一个list。
(+ 1 2) ; 3
'(+ 1 2) ; 一个list，第一个pair的car指向符号+，第二个pair的car指向符号1，等。
(define a (1 2 3)) ; 用list存储该compound expr后，对其求值。
'(define a (1 2 3)) ; 一个list，第三个pair的car指向又一个list，(1 2 3)。
```



https://stackoverflow.com/questions/34984552/what-is-the-difference-between-quote-and-list

https://cs61a.org/articles/scheme-spec.html#about-this-specification

