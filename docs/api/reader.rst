The Reader Monad
================

.. automodule:: hymn.types.reader
  :members: Reader, asks, local, lookup, reader, reader_m
  :show-inheritance:

.. data:: unit

  the unit of reader monad

.. function:: run

  alias of :meth:`Reader.run`

.. data:: ask

  fetch the value of the environment


Hy Specific API
---------------

.. class:: reader-m

  alias of :class:`Reader`


Function
^^^^^^^^

.. function:: <-

  alias of :func:`lookup`


Examples
--------


Do Notation
^^^^^^^^^^^

.. code-block:: clojure

  => (require hymn.dsl)
  => (import [hymn.types.reader [ask]])
  => (.run (do-monad [e ask] (inc e)) 41)
  42


Operations
^^^^^^^^^^

:func:`asks` create a reader with a function, :func:`reader` is an alias of
:func:`asks`

.. code-block:: clojure

  => (require hymn.dsl)
  => (import [hymn.types.reader [asks reader]])
  => (.run (do-monad [h (asks first)] h) [5 4 3 2 1])
  5
  => (.run (do-monad [h (reader second)] h) [5 4 3 2 1])
  4

:func:`ask` fetch the environment

.. code-block:: clojure

  => (require hymn.dsl)
  => (import [hymn.types.reader [ask]])
  => (.run ask 42)
  42
  => (.run (do-monad [e ask] (inc e)) 42)
  43

:func:`local` run the reader with modified environment

.. code-block:: clojure

  => (import [hymn.types.reader [ask local]])
  => (.run ask 42)
  42
  => (.run ((local inc) ask) 42)
  43

:func:`lookup` get the value of key in environment, :data:`<-` is an alias of
:func:`lookup`

.. code-block:: clojure

  => (require hymn.dsl)
  => (import [hymn.types.reader [lookup <-]])
  => (.run (lookup 1) [1 2 3])
  2
  => (.run (lookup 'b) {'a 1 'b 2})
  2
  => (.run (<- 1) [1 2 3])
  2
  => (.run (<- 'b) {'a 1 'b 2})
  2
  => (.run (do-monad [a (<- 'a) b (<- 'b)] (+ a b)) {'a 25 'b 17})
  42
