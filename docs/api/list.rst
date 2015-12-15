The List Monad
==============

.. automodule:: hymn.types.list
  :members:
  :show-inheritance:

.. data:: zero

  the zero of list monad, an empty list


Hy Specific API
---------------

.. class:: list-m

  alias of :class:`List`


Reader Macro
^^^^^^^^^^^^

.. function:: * [seq]

  turn iterable ``seq`` into a :class:`List`


Examples
--------


Do Notation
^^^^^^^^^^^

.. code-block:: clojure

  => (require hymn.dsl)
  => (import [hymn.types.list [list-m]])
  => (list (do-monad [a (list-m [1 2 3])] (inc a)))
  [2, 3, 4]
  => (list (do-monad [a (list-m [1 2 3]) b (list-m [4 5 6])] (+ a b)))
  [5, 6, 7, 6, 7, 8, 7, 8, 9]
  => (list (do-monad [a (list-m "123") b (list-m "xy")] (+ a b)))
  ['1x', '1y', '2x', '2y', '3x', '3y']


Do Notation with :when
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: clojure

  => (require hymn.dsl)
  => (import [hymn.types.list [list-m]])
  => (list (do-monad
  ...         [a (list-m [1 2 4])
  ...          b (list-m [1 2 4])
  ...          :when (!= a b)]
  ...         (/ a b)))
  [0.5, 0.25, 2.0, 0.5, 4.0, 2.0]


Operations
^^^^^^^^^^

:attr:`~List.unit` accepts any number of initial values

.. code-block:: clojure

  => (list (list-m.unit))
  []
  => (list (list-m.unit 1))
  [1]
  => (list (list-m.unit 1 3))
  [1, 3]
  => (list (list-m.unit 1 3 5))
  [1, 3, 5]

:func:`fmap` works like the builtin `map` function, but creates :class:`List`
instead of the builtin `list`

.. code-block:: clojure

  => (require hymn.dsl)
  => (import [hymn.types.list [fmap list-m]])
  => (instance? list-m (fmap inc [0 1 2]))
  True
  => (for [e (fmap inc [0 1 2])] (print e))
  1
  2
  3


Reader Macro
^^^^^^^^^^^^

.. code-block:: clojure

  => (require hymn.types.list)
  => (import [hymn.types.list [list-m]])
  => (instance? list-m #*[0 1 2])
  True
  => (list (do-monad [a #*(range 10) :when (odd? a)] (* a 2)))
  [2, 6, 10, 14, 18]
