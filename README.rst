==========================================
Hy Monad Notation - a monad library for Hy
==========================================


Introduction
============

Hymn is a monad library for Hy/Python, with do notation for monad
comprehension.

Code are better than words.

The continuation monad

.. code-block:: clojure

  => (require hymn.dsl)
  => (import [hymn.types.continuation [cont-m call-cc]])
  => ;; computations in continuation passing style
  => (defn double [x] (cont-m.unit (* x 2)))
  => (def length (cont-m.monadic len))
  => ;; chain with bind
  => (.run (>> (cont-m.unit [1 2 3]) length double))
  6
  => (defn square [n] (call-cc (fn [k] (k (** n 2)))))
  => (.run (square 12))
  144
  => (.run (square 12) inc)
  145
  => (.run (square 12) str)
  '144'
  => (.run (do-monad [sqr (square 42)] (.format "answer^2 = {}" sqr)))
  'answer^2 = 1764'


The either monad

.. code-block:: clojure

  => (require hymn.dsl)
  => (import [hymn.types.either [Left Right either failsafe]])
  => ;; do notation with either monad
  => (do-monad [a (Right 1) b (Right 2)] (/ a b))
  Right(0.5)
  => (do-monad [a (Right 1) b (Left 'nan)] (/ a b))
  Left(nan)
  => ;; failsafe is a function decorator that wraps return value into either
  => (def safe-div (failsafe /))
  => ;; returns Right if nothing wrong
  => (safe-div 4 2)
  Right(2.0)
  => ;; returns Left when bad thing happened, like exception being thrown
  => (safe-div 1 0)
  Left(ZeroDivisionError('division by zero',))
  => ;; function either tests the value and call functions accordingly
  => (either print inc (safe-div 4 2))
  3.0
  => (either print inc (safe-div 1 0))
  division by zero

The identity monad

.. code-block:: clojure

  => (require hymn.dsl)
  => (import [hymn.types.identity [identity-m]])
  => ;; do notation with identity monad is like let binding
  => (do-monad [a (identity-m 1) b (identity-m 2)] (+ a b))
  Identity(3)


The list monad

.. code-block:: clojure

  => (require hymn.dsl)
  => (import [hymn.types.list [list-m]])
  => ;; use list-m contructor to turn sequence into list monad
  => (def xs (list-m (range 2)))
  => (def ys (list-m (range 3)))
  => ;; do notation with list monad is list comprehension
  => (list (do-monad [x xs y ys :when (not (zero? y))] (/ x y)) )
  [0.0, 0.0, 1.0, 0.5]
  => ;; * is the reader macro for list-m
  => (list (do-monad [x #*(range 2) y #*(range 3) :when (not (zero? y))] (/ x y)) )
  [0.0, 0.0, 1.0, 0.5]

The maybe monad

.. code-block:: clojure

  => (require hymn.dsl)
  => (import [hymn.types.maybe [Just Nothing maybe]])
  => ;; do notation with maybe monad
  => (do-monad [a (Just 1) b (Just 1)] (/ a b))
  Just(1.0)
  => ;; Nothing yields Nothing
  => (do-monad [a Nothing b (Just 1)] (/ a b))
  Nothing
  => ;; maybe is a function decorator that wraps return value into maybe
  => ;; a safe-div with maybe monad
  => (def safe-div (maybe /))
  => (safe-div 42 42)
  Just(1.0)
  => (safe-div 42 'answer)
  Nothing
  => (safe-div 42 0)
  Nothing

The reader monad

.. code-block:: clojure

  => (require hymn.dsl)
  => (import [hymn.types.reader [lookup]])
  => ;; do notation with reader monad, lookup assumes the environment is subscriptable
  => (def r (do-monad [a (lookup 'a) b (lookup 'b)] (+ a b)))
  => ;; run reader monad r with environment
  => (.run r {'a 1 'b 2})
  3

The state monad

.. code-block:: clojure

  => (require hymn.dsl)
  => (import [hymn.types.state [lookup set-value]])
  => ;; do notation with state monad, set-value sets the value with key in the state
  => (def s (do-monad [a (lookup 'a) _ (set-value 'b (inc a))] a))
  => ;; run state monad s with initial state
  => (.run s {'a 1})
  (, 1 {'a 1 'b 2})

The writer monad

.. code-block:: clojure

  => (require hymn.dsl)
  => (import [hymn.types.writer [tell]])
  => ;; do notation with writer monad
  => (do-monad [_ (tell "hello") _ (tell " world")] nil)
  StrWriter((None, 'hello world'))
  => ;; int is monoid, too
  => (.execute (do-monad [_ (tell 1) _ (tell 2) _ (tell 3)] nil))
  6

Operations on monads

.. code-block:: clojure

  => (require hymn.dsl)
  => (import [hymn.operations [lift]])
  => ;; lift promotes function into monad
  => (def m+ (lift +))
  => ;; lifted function can work on any monad
  => ;; on the maybe monad
  => (import [hymn.types.maybe [Just Nothing]])
  => (m+ (Just 1) (Just 2))
  Just(3)
  => (m+ (Just 1) Nothing)
  Nothing
  => ;; on the either monad
  => (import [hymn.types.either [Left Right]])
  => (m+ (Right 1) (Right 2))
  Right(3)
  => (m+ (Left 1) (Right 2))
  Left(1)
  => ;; on the list monad
  => (import [hymn.types.list [list-m]])
  => (list (m+ (list-m "ab") (list-m "123")))
  ['a1', 'a2', 'a3', 'b1', 'b2', 'b3']
  => (list (m+ (list-m "+-") (list-m "123") (list-m "xy")))
  ['+1x', '+1y', '+2x', '+2y', '+3x', '+3y', '-1x', '-1y', '-2x', '-2y', '-3x', '-3y']
  => ;; can be used as normal function
  => (reduce m+ [(Just 1) (Just 2) (Just 3)])
  Just(6)
  => (reduce m+ [(Just 1) Nothing (Just 3)])
  Nothing
  => ;; <- is an alias of lookup
  => (import [hymn.types.reader [<-]])
  => ;; ^ is the reader macro for lift
  => (def p (#^print (<- 'message) :end (<- 'end)))
  => (.run p {'message "Hello world" 'end "!\n"})
  Hello world!
  => ;; random number - linear congruential generator
  => (import [hymn.types.state [get-state set-state]])
  => (def random (>> get-state (fn [s] (-> s (* 69069) inc (% (** 2 32)) set-state))))
  => (.run random 1234)
  (1234, 85231147)
  => ;; random can be even shorter by using modify
  => (import [hymn.types.state [modify]])
  => (def random (modify (fn [s] (-> s (* 69069) inc (% (** 2 32))))))
  => (.run random 1234)
  (1234, 85231147)
  => ;; use replicate to do computation repeatly
  => (import [hymn.operations [replicate]])
  => (.evaluate (replicate 5 random) 42)
  [42, 2900899, 2793697416, 2186085609, 1171637142]
  => ;; sequence on writer monad
  => (import [hymn.operations [sequence]])
  => (import [hymn.types.writer [tell]])
  => (.execute (sequence (map tell (range 1 101))))
  5050

Using Hymn in Python

.. code-block:: python

  >>> from hymn.dsl import *
  >>> sequence(map(tell, range(1, 101))).execute()
  5050
  >>> msum = lift(sum)
  >>> msum(sequence(map(maybe(int), "12345")))
  Just(15)
  >>> msum(sequence(map(maybe(int), "12345a")))
  Nothing
  >>> @failsafe
  ... def safe_div(a, b):
  ...     return a / b
  ...
  >>> safe_div(1.0, 2)
  Right(0.5)
  >>> safe_div(1, 0)
  Left(ZeroDivisionError(...))


Requirements
============

- hy >= 0.11.0


Installation
============

Install from PyPI::

  pip install hymn

Install from source, download source package, decompress, then ``cd`` into
source directory, run::

  make install


License
=======

BSD New, see LICENSE for details.


Links
=====

Documentation:
  http://hymn.readthedocs.org/

Issue Tracker:
  https://github.com/pyx/hymn/issues/

Source Package @ PyPI:
  https://pypi.python.org/pypi/hymn/

Mercurial Repository @ bitbucket:
  https://bitbucket.org/pyx/hymn/

Git Repository @ Github:
  https://github.com/pyx/hymn/
