def cascade1(n):
    if n<10:
        print(n)
    else:
        print(n) # 递归前操作。
        cascade1(n//10);
        print(n) # 先递归调用到最底层，回溯时再操作。

def cascade2(n):
    print(n)
    if n>=10:
        cascade2(n//10);
        print(n);

cascade2(1234);

def inverse_cascade(n):
    grow(n) # 注意grow自己是一个递归函数，这里递归调用的是grow，而不是inverse_cascade。故grow会自己先展开然后收缩。
    print(n) # 这个print实际上只调用一次，因为这个函数体中根本没有递归调用inverse_cascade。
    shrink(n)

def f_then_g(f, g, n):
    if n:
        f(n)
        g(n)

grow = lambda n: f_then_g(grow, print, n//10)
shrink = lambda n: f_then_g(print, shrink, n//10);

inverse_cascade(1234)
