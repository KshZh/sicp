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

注意表达式有primitive/atomic expr和compound expr，不要一提到表达式就一股脑认为是compound expr。

对递归/有闭包性质的数据结构进行编程时需要注意的地方，也是很容易忽视的地方。

```python
def scheme_read(src):
    """Read the next expression from SRC, a Buffer of tokens.

    >>> scheme_read(Buffer(tokenize_lines(['nil'])))
    nil
    >>> scheme_read(Buffer(tokenize_lines(['1'])))
    1
    >>> scheme_read(Buffer(tokenize_lines(['true'])))
    True
    >>> scheme_read(Buffer(tokenize_lines(['(+ 1 2)'])))
    Pair('+', Pair(1, Pair(2, nil)))
    """
    # 设计递归不仅仅要设计终止边界、如何缩小问题规模、如何利用子问题的解构造出原问题的解。
    # XXX 设计递归的另一个很重要的点是定义好函数的行为，如输入什么，输出什么。
    # 这里scheme_read输入token Buffer，消耗其中足够多的token，然后输出一个用python内部数据/数据结构表示的表达式。
    # 注意表达式有primitive expr和compound expr，不要一提到表达式就一股脑认为是compound expr。
    # 而read_tail expects to read the rest of a list or pair,
    # assuming the open parenthesis of that list or pair has already been removed by scheme_read.
    if src.current() is None:
        raise EOFError
    # BEGIN PROBLEM 1/2
    "*** YOUR CODE HERE ***"
    token = src.pop_first()
    if token == '(':
        return read_tail(src)
    # 注意这里不是`if token is nil`，因为在我们的分词器(tokenizer)看来，nil和x这样的符号并没有什么区别，都会使用字符串来表示/存储。
    if token is 'nil':
        return nil
    if token not in DELIMITERS:
        return token
    # END PROBLEM 1/2

def read_tail(src):
    """Return the remainder of a list in SRC, starting before an element or ).

    >>> read_tail(Buffer(tokenize_lines([')'])))
    nil
    >>> read_tail(Buffer(tokenize_lines(['2 3)'])))
    Pair(2, Pair(3, nil))
    """
    try:
        if src.current() is None:
            raise SyntaxError('unexpected end of file')
        # BEGIN PROBLEM 1
        "*** YOUR CODE HERE ***"
        if src.current() == ')':
            src.pop_first()
            return nil
        # 不是直接`first = src.pop_first()`，因为src.current()可能是由一个compound expr（即又一个list）而不是primitive expr。
        # XXX 这就是在对递归/有闭包性质的数据结构进行编程时需要注意的地方，也是很容易忽视的地方。
        first = scheme_read(src)
        rest = read_tail(src)
        return Pair(first, rest) # cons up when cdring down the list.
        # END PROBLEM 1
    except EOFError:
        raise SyntaxError('unexpected end of file')
```

## Part II: The Evaluator

- While built-in procedures follow the normal rules of evaluation (evaluate operator, evaluate operands, apply operator to operands), applying the operator does *not* create a new frame.
- 