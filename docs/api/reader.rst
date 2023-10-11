The Reader Monad
================

.. module:: hymn.types.reader

  :members: Reader, asks, local, lookup, reader, reader_m

.. class:: Reader

  the reader monad

  computations which read values from a shared environment

  .. method:: bind(self, f)

    the bind operation of :class:`Reader`

  .. method:: unit(cls, value)
    :classmethod:

    the unit of reader monad

  .. method:: local(self, f)

    return a reader that execute computation in modified environment

  .. method:: run(self, e)

    run the reader and extract the final vaule

.. function:: asks(f)
.. function:: reader(f)

  create a simple reader action from :code:`f`

.. function:: local(f)

  executes a computation in a modified environment, :code:`f :: e -> e`

.. Function:: lookup(key)

  create a lookup reader of :code:`key` in the environment

.. data:: ask

  fetch the value of the environment


Hy Specific API
---------------

.. class:: reader-m

  alias of :class:`Reader`


.. function:: <-

  alias of :func:`lookup`


Examples
--------


Do Notation
^^^^^^^^^^^

.. code-block:: clojure

  => (import hymn.types.reader [ask])
  => (require hymn.macros [do-monad-return])
  => (.run (do-monad-return [e ask] (+ e 1)) 41)
  42


Operations
^^^^^^^^^^

:func:`asks` creates a reader with a function, :func:`reader` is an alias of
:func:`asks`

.. code-block:: clojure

  => (import hymn.types.reader [asks reader])
  => (require hymn.macros [do-monad-return])
  => (defn first [c] (get c 0))
  => (defn second [c] (get c 1))
  => (.run (do-monad-return [h (asks first)] h) [5 4 3 2 1])
  5
  => (.run (do-monad-return [h (reader second)] h) [5 4 3 2 1])
  4

Use :func:`ask` to fetch the environment

.. code-block:: clojure

  => (import hymn.types.reader [ask])
  => (.run ask 42)
  42
  => (require hymn.macros [do-monad-return])
  => (.run (do-monad-return [e ask] (+ e 1)) 42)
  43

:func:`local` runs the reader with modified environment

.. code-block:: clojure

  => (import hymn.types.reader [ask local])
  => (.run ask 42)
  42
  => (.run ((local (fn [x] (+ x 1))) ask) 42)
  43

Use :func:`lookup` to get the value of key in environment, :code:`<-` is an
alias of :func:`lookup`

.. code-block:: clojure

  => (import hymn.types.reader [lookup <-])
  => (.run (lookup 1) [1 2 3])
  2
  => (.run (lookup 'b) {'a 1 'b 2})
  2
  => (.run (<- 1) [1 2 3])
  2
  => (.run (<- 'b) {'a 1 'b 2})
  2
  => (require hymn.macros [do-monad-return])
  => (.run (do-monad-return [a (<- 'a) b (<- 'b)] (+ a b)) {'a 25 'b 17})
  42
