# Copyright (c) 2021 Daniel C. Moura
# ** LINK TO ARTICLE GOES HERE **
# linkedin.com/in/dmoura
# twitter.com/daniel_c_moura

# running this file:
# python3 -O linear_search.py 

from time import process_time
from numba import jit, int64, boolean, njit
from functools import reduce
import numpy as np
import gc


### functions under evaluation ###

# 9.13 seconds when vec is a native list
# 0.57 seconds when vec is a numpy array
def in_search(vec, x):
    return x in vec

# 0.57 seconds when vec is a numpy array
def vec_search(vec, x):
    return np.any(vec==x)

#  18.70 seconds when vec is a native list
# 121.48 seconds when vec is a numpy array
def foreach_search(vec, x):
    for v in vec:
        if v == x:
            return True
    return False

# 0.47 seconds when vec is a numpy array with numba
@njit #(boolean(int64[:], int64))
def foreach_search_jit(vec, x):
    for v in vec:
        if v == x:
            return True
    return False

#  40.75 seconds when vec is a native list
# 161.36 seconds when vec is a numpy array
def for_search(vec, x):
    for i in range(len(vec)):
        if vec[i] == x:
            return True
    return False

# 0.55 seconds when vec is a numpy array with numba
@njit #(boolean(int64[:], int64))
def for_search_jit(vec, x):
    for i in range(len(vec)):
        if vec[i] == x:
            return True
    return False


# other options...

def mapr_search(vec, x):
    return reduce(lambda a,b: a|b,  map(lambda y: y==x, vec), False)

def gen_search(vec, x):
    return next((a for a in vec if a==x), -1) >= 0

def index_search(vec, x):
    try:
        vec.index(x)
        return True
    except ValueError:
        return False

def while_search(vec, x):
    n = len(vec)
    i = 0
    while i < n:
        if vec[i] == x:
            return True
        i += 1
    return False


# other options with numpy array...

# 0.57 seconds when vec is a numpy array
def mapr_search(vec, x):
    return np.logical_or.reduce(map(lambda y: y==x, vec))

def count_search(vec, x):
    return np.count_nonzero(vec==x) > 0

def where_search(vec, x):
    return np.where(vec==x)[0].size > 0


### aux functions ###

def bench(label, f, v):
    f(v[1:10], 0) #warmup

    print(f"{label}:")
    for r in range(3): # three runs
        gc.collect() #cleaning the garbage before each measurement
        start_time = process_time()
        nmatches = sum([f(v, x) for x in range(1,1001)])            
        end_time = process_time()
        print(f"\telapsed CPU time: {end_time-start_time} seconds")
        print(f"\t\tmatches: {nmatches}")    
    print()


### main ###

def main():
    with open('vec.txt') as my_file:
        # reads to a native list
        l = [int(line) for line in my_file] 

    print(len(l), "records")
    a = np.asarray(l) # NumPy array

    bench("IN",                 in_search,          l)
    bench("IN (NumPy)",         in_search,          a)
    bench("VEC (NumPy)",        vec_search,         a)
    bench("FOREACH",            foreach_search,     l)
    bench("FOREACH (NumPy)",    foreach_search,     a)
    bench("FOREACH (Numba)",    foreach_search_jit, a)
    bench("FOR",                for_search,         l)
    bench("FOR (NumPy)",        for_search,         a)
    bench("FOR (Numba)",        for_search_jit,     a)

main()
