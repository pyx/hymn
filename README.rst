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

  => (import [hymn.types.continuation [cont-m call-cc]])
  => ;; computations in continuation passing style
  => (defn double [x] (cont-m.unit (* x 2)))
  => (setv length (cont-m.monadic len))
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
  => (require [hymn.macros [do-monad-return]])
  => (.run (do-monad-return [sqr (square 42)] (.format "answer^2 = {}" sqr)))
  'answer^2 = 1764'

The either monad

.. code-block:: clojure

  => (import [hymn.types.either [Left Right either failsafe]])
  => (require [hymn.macros [do-monad-return]])
  => ;; do notation with either monad
  => (do-monad-return [a (Right 1) b (Right 2)] (/ a b))
  Right(0.5)
  => (do-monad-return [a (Right 1) b (Left NaN)] (/ a b))
  Left(nan)
  => ;; failsafe is a function decorator that wraps return value into either
  => (setv safe-div (failsafe /))
  => ;; returns Right if nothing wrong
  => (safe-div 4 2)
  Right(2.0)
  => ;; returns Left when bad thing happened, like exception being thrown
  => (safe-div 1 0)
  Left(ZeroDivisionError('division by zero',))
  => ;; function either tests the value and calls functions accordingly
  => (either print inc (safe-div 4 2))
  3.0
  => (either print inc (safe-div 1 0))
  division by zero

The identity monad

.. code-block:: clojure

  => (import [hymn.types.identity [identity-m]])
  => (require [hymn.macros [do-monad-return]])
  => ;; do notation with identity monad is like let binding
  => (do-monad-return [a (identity-m 1) b (identity-m 2)] (+ a b))
  Identity(3)

The lazy monad

.. code-block:: clojure

  => (import [hymn.types.lazy [force]])
  => (require [hymn.types.lazy [lazy]])
  => ;; lazy computation implemented as monad
  => ;; macro lazy creates deferred computation
  => (setv a (lazy (print "evaluate a") 42))
  => ;; the computation is deferred, notice the value is shown as '_'
  => a
  Lazy(_)
  => ;; evaluate it
  => (.evaluate a)
  evaluate a
  42
  => ;; now the value is cached
  => a
  Lazy(42)
  => ;; calling evaluate again will not trigger the computation
  => (.evaluate a)
  42
  => (setv b (lazy (print "evaluate b") 21))
  => b
  Lazy(_)
  => ;; force evaluate the computation, same as calling .evaluate on the monad
  => (force b)
  evaluate b
  21
  => ;; force on values other than lazy return the value unchanged
  => (force 42)
  42
  => (require [hymn.macros [do-monad-return]])
  => ;; do notation with lazy monad
  => (setv c (do-monad-return
  ...          [x (lazy (print "get x") 1)
  ...           y (lazy (print "get y") 2)]
  ...          (+ x y)))
  => ;; the computation is deferred
  => c
  Lazy(_)
  => ;; do it!
  => (force c)
  get x
  get y
  3
  => ;; again
  => (force c)
  3

The list monad

.. code-block:: clojure

  => (import [hymn.types.list [list-m]])
  => (require [hymn.macros [do-monad-return]])
  => ;; use list-m contructor to turn sequence into list monad
  => (setv xs (list-m (range 2)))
  => (setv ys (list-m (range 3)))
  => ;; do notation with list monad is list comprehension
  => (list (do-monad-return [x xs y ys :when (not (zero? y))] (/ x y)) )
  [0.0, 0.0, 1.0, 0.5]
  => (require [hymn.types.list [~]])
  => ;; ~ is the tag macro for list-m
  => (list
  ...  (do-monad-return
  ...    [x #~ (range 2)
  ...     y #~ (range 3)
  ...     :when (not (zero? y))]
  ...    (/ x y)))
  [0.0, 0.0, 1.0, 0.5]

The maybe monad

.. code-block:: clojure

  => (import [hymn.types.maybe [Just Nothing maybe]])
  => (require [hymn.macros [do-monad-return]])
  => ;; do notation with maybe monad
  => (do-monad-return [a (Just 1) b (Just 1)] (/ a b))
  Just(1.0)
  => ;; Nothing yields Nothing
  => (do-monad-return [a Nothing b (Just 1)] (/ a b))
  Nothing
  => ;; maybe is a function decorator that wraps return value into maybe
  => ;; a safe-div with maybe monad
  => (setv safe-div (maybe /))
  => (safe-div 42 42)
  Just(1.0)
  => (safe-div 42 'answer)
  Nothing
  => (safe-div 42 0)
  Nothing

The reader monad

.. code-block:: clojure

  => (import [hymn.types.reader [lookup]])
  => (require [hymn.macros [do-monad-return]])
  => ;; do notation with reader monad,
  => ;; lookup assumes the environment is subscriptable
  => (setv r (do-monad-return [a (lookup 'a) b (lookup 'b)] (+ a b)))
  => ;; run reader monad r with environment
  => (.run r {'a 1 'b 2})
  3

The state monad

.. code-block::

  => (import [hymn.types.state [lookup set-value]])
  => (require [hymn.macros [do-monad-return]])
  => ;; do notation with state monad,
  => ;; set-value sets the value with key in the state
  => (setv s (do-monad-return [x (lookup "a") _ (set-value "b" (inc x))] x))
  => ;; run state monad s with initial state
  => (.run s {"a" 1})
  (1, {'a': 1, 'b': 2})

The writer monad

.. code-block:: clojure

  => (import [hymn.types.writer [tell]])
  => (require [hymn.macros [do-monad-return]])
  => ;; do notation with writer monad
  => (do-monad-return [_ (tell "hello") _ (tell " world")] None)
  StrWriter((None, 'hello world'))
  => ;; int is monoid, too
  => (.execute (do-monad-return [_ (tell 1) _ (tell 2) _ (tell 3)] None))
  6

Operations on monads

.. code-block:: clojure

  => (import [hymn.operations [lift]])
  => ;; lift promotes function into monad
  => (setv m+ (lift +))
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
  => (require [hymn.macros [^]])
  => ;; ^ is the tag macro for lift
  => (setv p (#^ print (<- 'message) :end (<- 'end)))
  => (.run p {'message "Hello world" 'end "!\n"})
  Hello world!
  => ;; pseudo random number - linear congruential generator
  => (import [hymn.types.state [get-state set-state]])
  => (setv random
  ...      (>> get-state
  ...          (fn [s] (-> s (* 69069) inc (% (** 2 32))
  ...          set-state))))
  => (.run random 1234)
  (1234, 85231147)
  => ;; random can be even shorter by using modify
  => (import [hymn.types.state [modify]])
  => (setv random (modify (fn [s] (-> s (* 69069) inc (% (** 2 32))))))
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

- hy >= 0.19.0

For hy version 0.14, please install hymn 0.8

For hy version 0.13, please install hymn 0.7.

For hy version 0.12, please install hymn 0.6.

For hy version 0.11 and earlier, please install hymn 0.5.

See Changelog section in documentation for details.


Installation
============

Install from PyPI::

  pip install hymn

Install from source, download source package, decompress, then :code:`cd` into
source directory, run::

  make install


License
=======

BSD New, see LICENSE for details.


Links
=====

Documentation:
  https://hymn.readthedocs.io/

Issue Tracker:
  https://github.com/pyx/hymn/issues/

Source Package @ PyPI:
  https://pypi.python.org/pypi/hymn/

Git Repository @ Github:
  https://github.com/pyx/hymn/

Git Repository @ Gitlab:
  https://gitlab.com/pyx/hymn/
