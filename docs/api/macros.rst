Macros
======

.. automodule:: hymn.macros

:code:`hymn.macros` provide macros for monad computations


Operation Macros
----------------

.. function:: do-monad [binding-forms expr]

  .. versionchanged:: 0.9

    This macro was named ``do-monad-m`` before version 0.9

  macro for sequencing monadic computations, a.k.a do notation in haskell

.. code-block:: clojure

  => (import [hymn.types.maybe [Just]])
  => (require [hymn.macros [do-monad]])
  => (do-monad [a (Just 41)] (m-return (inc a)))
  Just(42)

.. function:: do-monad-return [binding-forms expr]

  .. versionchanged:: 0.9

    This macro was named ``do-monad`` before version 0.9

  macro for sequencing monadic computations, with automatic return

.. code-block:: clojure

  => (import [hymn.types.maybe [Just]])
  => (require [hymn.macros [do-monad-return]])
  => (do-monad-return [a (Just 41)] (inc a))
  Just(42)

.. function:: do-monad-with [monad binding-forms expr]

  macro for sequencing monadic composition, with said monad as default.

  useful when the only binding form is :code:`:when`, we do not know which
  monad we are working with otherwise

.. code-block:: clojure

  => (import [hymn.types.maybe [maybe-m]])
  => (require [hymn.macros [do-monad-with]])
  => (do-monad-with maybe-m [:when True] 42)
  Just(42)
  => (do-monad-with maybe-m [:when False] 42)
  Nothing

All do monad macros support :code:`:let` binding, like this:

.. code-block:: clojure

  => (import [hymn.types.maybe [Just]])
  => (require [hymn.macros [do-monad-return]])
  => (defn half [x]
  ...  (do-monad-return
  ...    [:let [two 2]
  ...     a x
  ...     :let [b (/ a two)]]
  ...    b))
  => (half (Just 42))
  Just(21.0)

All do monad macros support :code:`:when` if the monad is of type
:class:`~hymn.types.monadplus.MonadPlus`.

.. code-block:: clojure

  => (import [hymn.types.maybe [maybe-m]])
  => (require [hymn.macros [do-monad-with]])
  => (defn div [a b] (do-monad-with maybe-m [:when (not (zero? b))] (/ a b)))
  => (div 1 2)
  Just(0.5)
  => (div 1 0)
  Nothing

.. function:: monad-> [init-value &rest actions]

  threading macro for monadic actions

.. code-block:: clojure

  => (import [hymn.types.maybe [maybe-m]])
  => (setv m-inc (maybe-m.monadic inc))
  => (setv m-div (maybe-m.monadic /))
  => (require [hymn.macros [monad->]])
  => ;; threading macro for monadic actions
  => (monad-> (maybe-m.unit 99) m-inc (m-div 5) (m-div 2))
  Just(10.0)
  => ;; is equivalent to
  => (require [hymn.macros [do-monad]])
  => (do-monad [a (maybe-m.unit 99) b (m-inc a) c (m-div b 5)] (m-div c 2))
  Just(10.0)

.. function:: monad->> [init-value &rest actions]

  threading tail macro for monadic actions

.. code-block:: clojure

  => (import [hymn.types.maybe [maybe-m]])
  => (setv m-inc (maybe-m.monadic inc))
  => (setv m-div (maybe-m.monadic /))
  => (require [hymn.macros [monad->>]])
  => ;; threading tail macro for monadic actions
  => (monad->> (maybe-m.unit 4) m-inc (m-div 25) (m-div 100))
  Just(20.0)
  => ;; is equivalent to
  => (require [hymn.macros [do-monad]])
  => (do-monad [a (maybe-m.unit 4) b (m-inc a) c (m-div 25 b)] (m-div 100 c))
  Just(20.0)

.. function:: m-for [[n seq] &rest expr]

  macro for sequencing monadic actions

.. code-block:: clojure

  => (import [hymn.types.maybe [maybe-m]])
  => (require [hymn.macros [m-for]])
  => ;; with simple monad, e.g. maybe
  => (m-for [a (range 3)] (maybe-m.unit a))
  Just([0, 1, 2])
  => ;; with reader monad
  => (import [hymn.types.reader [<-]])
  => (setv readers
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

.. function:: with-monad [monad &rest exprs]

  provide default function m-return as the unit of the monad

.. code-block:: clojure

  => (import [hymn.types.maybe [maybe-m]])
  => (require [hymn.macros [m-when with-monad]])
  => (with-monad maybe-m (m-when (even? 1) (m-return 42)))
  Just(None)
  => (with-monad maybe-m (m-when (even? 2) (m-return 42)))
  Just(42)

.. function:: monad-comp [expr binding-forms &optional condition]

  different syntax for :code:`do-monad-return`, in the style of list/dict/set
  comprehensions, the :code:`condition` part is optional and can only be used
  with :class:`~hymn.types.monadplus.MonadPlus` as in :code:`do-monad-return`

.. code-block:: clojure

  => (import [hymn.types.maybe [Just]])
  => (require [hymn.macros [monad-comp]])
  => (monad-comp (+ a b) [a (Just 1) b (Just 2)])
  Just(3)
  => (monad-comp (/ a b) [a (Just 1) b (Just 0)] (not (zero? b)))
  Nothing
  => (import [hymn.types.list [list-m]])
  => (list (monad-comp (/ a b) [a (list-m [1 2]) b (list-m [4 8])]))
  [0.25, 0.125, 0.5, 0.25]
  => (list (monad-comp (/ a b) [a (list-m [1 2]) b (list-m [0 1])] (not (zero? b))))
  [1.0, 2.0]


Tag Macros
----------

.. function:: ^ [f]

  :func:`lift` tag macro, :code:`#^ f` is expanded to :code:`(lift f)`

.. code-block:: clojure

  => (import [hymn.types.maybe [Just Nothing]])
  => (require [hymn.macros [^]])
  => (#^ + (Just 1) (Just 2))
  Just(3)
  => (#^ + (Just 1) Nothing)
  Nothing

.. function:: = [value]

  tag macro for :code:`m-return`, the :code:`unit` inside do-monad-return macros,
  :code:`#= v` is expanded to :code:`(m-return v)`

.. code-block:: clojure

  => (import [hymn.types.maybe [Just maybe-m]])
  => (require [hymn.macros [= do-monad do-monad-with]])
  => (do-monad-with maybe-m [a #= 1 b #= 2] (+ a b))
  Just(3)
  => (do-monad [a (Just 1)] #= (inc a))
  Just(2)
