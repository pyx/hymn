Monad Operations
================

.. automodule:: hymn.operations

:code:`hymn.operations` provide operations and macros for monad computations


Macros
------

.. function:: do-monad [binding-forms expr]

  macro for sequencing monadic computations, with automatic return

.. code-block:: clojure

  => (require hymn.operations)
  => (import [hymn.types.maybe [Just]])
  => (do-monad [a (Just 41)] (inc a))
  Just(42)

.. function:: do-monad-m [binding-forms expr]

  macro for sequencing monadic computations, a.k.a do notation in haskell

.. code-block:: clojure

  => (require hymn.operations)
  => (import [hymn.types.maybe [Just]])
  => (do-monad [a (Just 41)] (m-return a))
  Just(42)

.. function:: do-monad-with [monad binding-forms expr]

  macro for sequencing monadic composition, with said monad as default.

  useful when the only binding form is :code:`:when`, we do not know which
  monad we are working with otherwise

.. code-block:: clojure

  => (require hymn.operations)
  => (import [hymn.types.maybe [maybe-m]])
  => (do-monad-with maybe-m [:when true] 42)
  Just(42)
  => (do-monad-with maybe-m [:when false] 42)
  Nothing

All do monad macros support :code:`:when` if the monad is of type
:class:`~hymn.types.monadplus.MonadPlus`.

.. code-block:: clojure

  => (require hymn.operations)
  => (import [hymn.types.maybe [maybe-m]])
  => (defn div [a b] (do-monad-with maybe-m [:when (not (zero? b))] (/ a b)))
  => (div 1 2)
  Just(0.5)
  => (div 1 0)
  Nothing

.. function:: m-when [test mexpr]

  conditional execution of monadic expressions

.. function:: with-monad [test &rest exprs]

  provide default function m-return as the unit of the monad

.. code-block:: clojure

  => (require hymn.Operation)
  => (import [hymn.types.maybe [maybe-m]])
  => (with-monad maybe-m (m-when (even? 1) (m-return 42)))
  Just(None)
  => (with-monad maybe-m (m-when (even? 2) (m-return 42)))
  Just(42)


Operation on Monads
-------------------

.. autofunction:: k_compose
.. function:: <=<

  alias of :func:`k_compose`

.. code-block:: clojure

  => (import [hymn.operations [k-compose <=<]])
  => (import [hymn.types.maybe [Just Nothing]])
  => (defn m-double [x] (if (numeric? x) (Just (* x 2)) Nothing))
  => (defn m-inc [x] (if (numeric? x) (Just (inc x)) Nothing))
  => (def +1*2 (k-compose m-double m-inc))
  => (+1*2 1)
  Just(4)
  => (def *2+1 (<=< m-inc m-double))
  => (*2+1 2)
  Just(5)
  => (*2+1 "two")
  Nothing

.. autofunction:: k_pipe
.. function:: >=>

  alias of :func:`k_compose`

.. code-block:: clojure

  => (import [hymn.operations [k-pipe >=>]])
  => (import [hymn.types.maybe [Just maybe]])
  => (def m-int (maybe int))
  => (defn m-array [n] (if (> n 0) (Just (* [0] n)) Nothing))
  => (def make-array (k-pipe m-int m-array))
  => (make-array 0)
  Nothing
  => (make-array 3)
  Just([0, 0, 0])
  => (def make-array (>=> m-int m-array))
  => (make-array 2)
  Just([0, 0])

.. autofunction:: lift

.. code-block:: clojure

  => (import [hymn.operations [lift]])
  => (import [hymn.types.maybe [Just]])
  => (def m+ (lift +))
  => (m+ (Just 1) (Just 2))
  Just(3)

.. autofunction:: replicate

.. code-block:: clojure

  => (import [hymn.operations [replicate]])
  => (import [hymn.types.list [list-m]])
  => (list (replicate 2 (list-m [0 1])))
  [[0, 0], [0, 1], [1, 0], [1, 1]]

.. autofunction:: sequence

.. code-block:: clojure

  => (import [hymn.operations [sequence]])
  => (import [hymn.types.writer [tell]])
  => (.execute (sequence (map tell (range 1 101))))
  5050
