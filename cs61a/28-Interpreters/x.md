Here is a brief overview of each of the Read-Eval-Print Loop components in our interpreter. Refer to this section as you work through the project as a reminder of how all the small pieces fit together!

- **Read**: This step parses user input (a string of Scheme code) into our interpreter's internal Python representation of Scheme expressions (e.g. Pairs).
  - *Lexical analysis* has already been implemented for you in the `tokenize_lines` function in `scheme_tokens.py`. This function returns a `Buffer` (from `buffer.py`) of tokens. You do not need to read or understand the code for this step.
  - *Syntactic analysis* happens in `scheme_reader.py`, in the `scheme_read` and `read_tail` functions. Together, these mutually recursive functions parse Scheme tokens into our interpreter's internal Python representation of Scheme expressions. You will complete both functions.
- **Eval**: This step evaluates Scheme expressions (represented in Python) to obtain values. Code for this step is in the main `scheme.py` file.
  - *Eval* happens in the `scheme_eval` function. If the expression is a call expression, it gets evaluated according to the rules for evaluating call expressions (you will implement this). If the expression being evaluated is a special form, the corresponding `do_?_form` function is called. You will complete several of the `do_?_form` functions.
  - *Apply* happens in the `scheme_apply` function. If the function is a built-in procedure, `scheme_apply` calls the `apply` method of that `BuiltInProcedure` instance. If the procedure is a user-defined procedure, `scheme_apply` creates a new call frame and calls `eval_all` on the body of the procedure, resulting in a mutually recursive eval-apply loop.
- **Print**: This step prints the `__str__` representation of the obtained value.
- **Loop**: The logic for the loop is handled by the `read_eval_print_loop` function in `scheme.py`. You do not need to understand the entire implementation.

**Exceptions.** As you develop your Scheme interpreter, you may find that Python raises various uncaught exceptions when evaluating Scheme expressions. As a result, your Scheme interpreter will halt. **Some of these may be the results of bugs in your program, but some might just be errors in user programs.** The former should be fixed by debugging your interpreter and the latter should be handled, usually by raising a `SchemeError`. All`SchemeError` exceptions are handled and printed as error messages by the `read_eval_print_loop` function in `scheme.py`. Ideally, there should *never* be unhandled Python exceptions for any input to your interpreter.

## Part I: The Reader

| Input Example  | Scheme Expression Type | Our Internal Representation                                  |
| :------------- | :--------------------- | :----------------------------------------------------------- |
| `scm> 1`       | Numbers                | Python's built-in `int` and `float` values                   |
| `scm> x`       | Symbols                | Python's built-in `string` values                            |
| `scm> #t`      | Booleans (`#t`, `#f`)  | Python's built-in `True`, `False` values                     |
| `scm> (+ 2 3)` | Combinations           | Instances of the `Pair` class, defined in `scheme_reader.py` |
| `scm> nil`     | `nil`                  | The `nil` object, defined in `scheme_reader.py`              |

**设计递归不仅仅要设计终止边界、如何缩小问题规模、如何利用子问题的解构造出原问题的解。设计递归的另一个很重要的点是定义好函数的行为，如输入什么，输出什么**。

注意表达式有primitive/atomic/self eval expr和compound expr，不要一提到表达式就一股脑认为是compound expr。

- scheme_read removes enough tokens from src to form a **single expression (primitive/atomic/self eval expr or compound expr)** and returns that expression in the correct internal representation (see above table).
- read_tail expects to read the rest of a list or pair, assuming the open parenthesis of that list or pair has already been removed by scheme_read. It will read expressions (and thus remove tokens) until the matching closing parenthesis ) is seen. This list of expressions is returned as a linked list of Pair instances.

In short, scheme_read returns the next single complete expression in the buffer and read_tail returns the rest of a list or pair in the buffer. Both functions mutate the buffer, removing the tokens that have already been processed.

上面提到scheme_read和read_tail的行为，多读几遍。

允许递归定义的数据结构，其相关的操作往往也是递归的。

```scheme
(eval (cons 'car '('(4 2))))
; cons会被求值，其car指向符号car，cdr指向一个list（这很重要，不能用不以nil结尾的list存储表达式），该list的第一个pair的car指向未求值的list (quote (4 2))，cdr指向nil。对这个list应用eval时，它会求值符号car，还对参数(quote (4 2))求值，得到list (4 2)，将实参应用到过程上，得到4。
```

https://cs61a.org/articles/scheme-spec.html#about-this-specification

