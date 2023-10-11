Monad Operations
================

.. module:: hymn.operations

:code:`hymn.operations` provide operations for monad computations


.. function:: k_compose(* monadic_funcs)

  right-to-left Kleisli composition of monads.

.. function:: <=<

  alias of :func:`k_compose`

.. code-block:: clojure

  => (import hymn.operations [k-compose <=<])
  => (import hymn.dsl [Just Nothing])
  => (import numbers [Number])
  => (defn m-double [x] (if (isinstance x Number) (Just (* x 2)) Nothing))
  => (defn m-inc [x] (if (isinstance x Number) (Just (+ x 1)) Nothing))
  => (setv +1*2 (k-compose m-double m-inc))
  => (+1*2 1)
  Just(4)
  => (setv *2+1 (<=< m-inc m-double))
  => (*2+1 2)
  Just(5)
  => (*2+1 "two")
  Nothing

.. function:: k_pipe

  left-to-right Kleisli composition of monads.

.. function:: >=>

  alias of :func:`k_pipe`

.. code-block:: clojure

  => (import hymn.operations [k-pipe >=>])
  => (import hymn.dsl [Just Nothing maybe])
  => (setv m-int (maybe int))
  => (defn m-array [n] (if (> n 0) (Just (* [0] n)) Nothing))
  => (setv make-array (k-pipe m-int m-array))
  => (make-array 0)
  Nothing
  => (make-array 3)
  Just([0, 0, 0])
  => (setv make-array (>=> m-int m-array))
  => (make-array 2)
  Just([0, 0])

.. function:: lift

  promote a function to a monad

.. code-block:: clojure

  => (import hymn.operations [lift])
  => (import hymn.dsl [Just])
  => (import hy.pyops [+])
  => (setv m+ (lift +))
  => (m+ (Just 1) (Just 2))
  Just(3)

.. function:: m_map

  map monadic function mf to a sequence, then execute that sequence of monadic
  values

.. function:: m-map

  alias of :func:`m_map`

.. code-block:: clojure

  => (import hymn.operations [m-map])
  => (import hymn.dsl [maybe-m])
  => (m-map maybe-m.unit (range 5))
  Just([0, 1, 2, 3, 4])
  => (m-map (maybe-m.monadic (fn [x] (+ x 1))) (range 5))
  Just([1, 2, 3, 4, 5])
  => (import hymn.dsl [tell])
  => (.execute (m-map tell (range 1 101)))
  5050

.. function:: replicate

  perform the monadic action n times, gathering the results

.. code-block:: clojure

  => (import hymn.operations [replicate])
  => (import hymn.dsl [list-m])
  => (list (replicate 2 (list-m [0 1])))
  [[0 0] [0 1] [1 0] [1 1]]

.. function:: sequence

  evaluate each action in the sequence, and collect the results

.. code-block:: clojure

  => (import hymn.operations [sequence])
  => (import hymn.dsl [tell])
  => (.execute (sequence (map tell (range 1 101))))
  5050
