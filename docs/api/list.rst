The List Monad
==============

.. module:: hymn.types.list

.. class:: List

  the list monad

  nondeterministic computation

  .. method:: fmap(self, f)

    return list obtained by applying :code:`f` to each element of the list

  .. method:: join

    join of list monad, concatenate list of list

  .. method:: append(self, other)

    the append operation of :class:`List`

  .. method:: concat(cls, list_of_lists)
    :classmethod:

    the concat operation of :class:`List`

  .. method:: plus(self, other)

    concatenate two lists

  .. method:: unit(cls, \*values)
    :classmethod:

    the unit, create a :class:`List` from :code:`values`

  .. property:: zero

    the zero of list monad, an empty list

.. function:: fmap(f, iterable)

  :code:`fmap` works like the builtin :code:`map`, but return a :class:`List`
  instead of :code:`list`


Hy Specific API
---------------

.. class:: list-m

  alias of :class:`List`


Reader Macro
^^^^^^^^^^^^

.. function:: @ [seq]

  turn iterable :code:`seq` into a :class:`List`

.. versionchanged:: 1.0.0

.. note::

  This is the new name of reader macro :code:`~`.


Examples
--------


Do Notation
^^^^^^^^^^^

.. code-block:: clojure

  => (import hymn.types.list [list-m])
  => (require hymn.macros [do-monad-return])
  => (list (do-monad-return [a (list-m [1 2 3])] (+ a 1)))
  [2 3 4]
  => (list (do-monad-return [a (list-m [1 2 3]) b (list-m [4 5 6])] (+ a b)))
  [5 6 7 6 7 8 7 8 9]
  => (list (do-monad-return [a (list-m "123") b (list-m "xy")] (+ a b)))
  ["1x" "1y" "2x" "2y" "3x" "3y"]


Do Notation with :when
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: clojure

  => (import hymn.types.list [list-m])
  => (require hymn.macros [do-monad-return])
  => (list (do-monad-return
  ...         [a (list-m [1 2 4])
  ...          b (list-m [1 2 4])
  ...          :when (!= a b)]
  ...         (/ a b)))
  [0.5 0.25 2.0 0.5 4.0 2.0]


Operations
^^^^^^^^^^

:attr:`~List.unit` accepts any number of initial values

.. code-block:: clojure

  => (import hymn.types.list [list-m])
  => (list (list-m.unit))
  []
  => (list (list-m.unit 1))
  [1]
  => (list (list-m.unit 1 3))
  [1 3]
  => (list (list-m.unit 1 3 5))
  [1 3 5]

:func:`fmap` works like the builtin `map` function, but creates :class:`List`
instead of the builtin `list`

.. code-block:: clojure

  => (import hymn.types.list [fmap list-m])
  => (isinstance (fmap (fn [x] (+ x 1)) [0 1 2]) list-m)
  True
  => (for [e (fmap (fn [x] (+ x 1)) [0 1 2])] (print e))
  1
  2
  3


Reader Macro
^^^^^^^^^^^^

.. code-block:: clojure

  => (import hymn.types.list [list-m])
  => (require hymn.types.list :readers [@])
  => (isinstance #@ [0 1 2] list-m)
  True
  => (require hymn.macros [do-monad-return])
  => (list (do-monad-return [a #@ (range 10) :when (= 1 (% a 2))] (* a 2)))
  [2 6 10 14 18]
