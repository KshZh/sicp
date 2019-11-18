"""This module implements the built-in data types of the Scheme language, along
with a parser for Scheme expressions.

In addition to the types defined in this file, some data types in Scheme are
represented by their corresponding type in Python:
    number:       int or float
    symbol:       string
    boolean:      bool
    unspecified:  None

The __repr__ method of a Scheme value will return a Python expression that
would be evaluated to the value, where possible.

The __str__ method of a Scheme value will return a Scheme expression that
would be read to the value, where possible.
"""

from __future__ import print_function  # Python 2 compatibility

import numbers

from ucb import main, trace, interact
from scheme_tokens import tokenize_lines, DELIMITERS
from buffer import Buffer, InputReader, LineReader

# Pairs and Scheme lists

class Pair(object):
    """A pair has two instance attributes: first and rest. rest must be a Pair or nil

    >>> s = Pair(1, Pair(2, nil))
    >>> s
    Pair(1, Pair(2, nil))
    >>> print(s)
    (1 2)
    >>> print(s.map(lambda x: x+4))
    (5 6)
    """
    # 可以把构造函数理解为scheme中的cons，实际上Pair(1, 2)的行为看起来和(cons 1 2)没什么区别。
    def __init__(self, first, rest):
        from scheme_builtins import scheme_valid_cdrp, SchemeError
        if not scheme_valid_cdrp(rest):
            raise SchemeError("cdr can only be a pair, nil, or a promise but was {}".format(rest))
        self.first = first
        self.rest = rest

    def __repr__(self):
        # 由于Pair是一个可以指向Pair的递归结构，所以它的一些操作往往也用递归实现，这样比较简洁易懂。
        return 'Pair({0}, {1})'.format(repr(self.first), repr(self.rest))

    def __str__(self):
        s = '(' + repl_str(self.first)
        rest = self.rest
        while isinstance(rest, Pair):
            s += ' ' + repl_str(rest.first)
            rest = rest.rest
        if rest is not nil:
            s += ' . ' + repl_str(rest)
        return s + ')'

    def __len__(self):
        n, rest = 1, self.rest
        while isinstance(rest, Pair):
            n += 1
            rest = rest.rest
        if rest is not nil: # list应该以nil结尾，这里的nil是nil类的单例，并不是关键字，尽管表面看起来像。
            raise TypeError('length attempted on improper list')
        return n

    def __eq__(self, p):
        if not isinstance(p, Pair):
            return False
        return self.first == p.first and self.rest == p.rest # 可能隐含递归调用，如果指向的也是一个Pair的话。

    def map(self, fn):
        """Return a Scheme list after mapping Python function FN to SELF."""
        mapped = fn(self.first)
        if self.rest is nil or isinstance(self.rest, Pair):
            return Pair(mapped, self.rest.map(fn)) # cons up when cdring down the list。
        else:
            raise TypeError('ill-formed list (cdr is a promise)')
    
    # p = Pair(2, Pair(2, nil))
    # list(p) = [2, 2]
    # 在apply函数时获取实参Pair链表中的值有用。
    def __iter__(self):
        yield self.first
        if self.rest is not nil:
            yield from iter(self.rest)

class nil(object):
    """The empty list"""

    def __repr__(self):
        return 'nil'

    def __str__(self):
        return '()'

    def __len__(self):
        return 0

    def map(self, fn):
        return self

nil = nil() # Assignment hides the nil class; there is only one instance

# Scheme list parser

# Quotation markers
quotes = {"'":  'quote',
          '`':  'quasiquote',
          ',':  'unquote'}

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
    # 注意不是表达式有primitive expr和compound expr，不要一提到表达式就一股脑认为是compound expr。
    # 而read_tail expects to read the rest of a list or pair,
    # assuming the open parenthesis of that list or pair has already been removed by scheme_read.
    if src.current() is None:
        raise EOFError
    # BEGIN PROBLEM 1/2
    "*** YOUR CODE HERE ***"
    token = src.pop_first()
    if token == '(':
        return read_tail(src)
    if token == 
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
        # 不是直接`first = src.pop_first()`，因为src.current()可能是由一个compound expr而不是primitive expr。
        # XXX 这就是在对递归/有闭包性质的数据结构进行编程时需要注意的地方，也是很容易忽视的地方。
        first = scheme_read(src)
        rest = read_tail(src)
        return Pair(first, rest) # cons up when cdring down the list.
        # END PROBLEM 1
    except EOFError:
        raise SyntaxError('unexpected end of file')

# Convenience methods

def buffer_input(prompt='scm> '):
    """Return a Buffer instance containing interactive input."""
    return Buffer(tokenize_lines(InputReader(prompt)))

def buffer_lines(lines, prompt='scm> ', show_prompt=False):
    """Return a Buffer instance iterating through LINES."""
    if show_prompt:
        input_lines = lines
    else:
        input_lines = LineReader(lines, prompt)
    return Buffer(tokenize_lines(input_lines))

def read_line(line):
    """Read a single string LINE as a Scheme expression."""
    return scheme_read(Buffer(tokenize_lines([line])))

def repl_str(val):
    """Should largely match str(val), except for booleans and undefined."""
    if val is True:
        return "#t"
    if val is False:
        return "#f"
    if val is None:
        return "undefined"
    if isinstance(val, numbers.Number) and not isinstance(val, numbers.Integral):
        return repr(val)  # Python 2 compatibility
    return str(val)

# Interactive loop
def read_print_loop():
    """Run a read-print loop for Scheme expressions."""
    while True:
        try:
            src = buffer_input('read> ')
            while src.more_on_line:
                expression = scheme_read(src)
                print('str :', expression)
                print('repr:', repr(expression))
        except (SyntaxError, ValueError) as err:
            print(type(err).__name__ + ':', err)
        except (KeyboardInterrupt, EOFError):  # <Control>-D, etc.
            print()
            return

@main
def main(*args):
    if len(args) and '--repl' in args:
        read_print_loop()