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

All do monad macros support :code:`:let` binding, like this:

.. code-block:: clojure

  => (require hymn.operations)
  => (import [hymn.types.maybe [Just]])
  => (defn half [x]
  ...  (do-monad
  ...    [:let [[two 2]]
  ...     a x
  ...     :let [[b (/ a two)]]]
  ...    b))
  => (half (Just 42))
  Just(21.0)

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

.. function:: m-for [[n seq] &rest expr]

  macro for sequencing monadic actions

.. code-block:: clojure

  => (require hymn.operations)
  => ;; with simple monad, e.g. maybe
  => (import [hymn.types.maybe [maybe-m]])
  => (m-for [a (range 3)] (maybe-m.unit a))
  Just([0, 1, 2])
  => ;; with reader monad
  => (import [hymn.types.reader [<-]])
  => (def readers
  ...  (m-for [a (range 5)]
  ...    (print "create reader" a)
  ...    (<- a)))
  create reader 0
  create reader 1
  create reader 2
  create reader 3
  create reader 4
  => (.run readers [11 12 13 14 15 16])
  [11, 12, 13, 14, 15]
  => (.run readers "abcdefg")
  ['a', 'b', 'c', 'd', 'e']
  => ;; with writer monad
  => (import [hymn.types.writer [tell]])
  => (.execute (m-for [a (range 1 101)] (tell a)))
  5050

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
  => (import [hymn.types.maybe [Just Nothing maybe]])
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

.. autofunction:: m_map
.. function:: m-map

  alias of :func:`m_map`

.. code-block:: clojure

  => (import [hymn.operations [m-map]])
  => (import [hymn.types.maybe [maybe-m]])
  => (m-map maybe-m.unit (range 5))
  Just([0, 1, 2, 3, 4])
  => (m-map (maybe-m.monadic inc) (range 5))
  Just([1, 2, 3, 4, 5])
  => (import [hymn.types.writer [tell]])
  => (.execute (m-map tell (range 1 101)))
  5050

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
