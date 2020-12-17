The State Monad
===============

.. automodule:: hymn.types.state
  :members: State, state_m, lookup, gets, modify, set_state, set_value,
            set_values, update, update_value
  :show-inheritance:

.. function:: unit

  alias of :meth:`State.unit`

.. function:: evaluate

  alias of :meth:`State.evaluate`

.. function:: execute

  alias of :meth:`State.execute`

.. function:: run

  alias of :meth:`State.run`

.. data:: get_state

  return the current state

.. function:: gets(f)
  :noindex:

  gets specific component of the state, using a projection function :code:`f`


Hy Specific API
---------------

.. class:: state-m

  alias of :class:`State`


Functions
^^^^^^^^^

.. function:: <-

  alias of :func:`lookup`

.. function:: <-state
.. function:: get-state

  alias of :func:`get_state`

.. function:: state<-
.. function:: set-state

  alias of :func:`set_state`

.. function:: set-value

  alias of :func:`set_value`

.. function:: set-values

  alias of :func:`set_values`

.. function:: update-value

  alias of :func:`update_value`


Examples
--------


Do Notation
^^^^^^^^^^^

.. code-block:: clojure

  => (import [hymn.types.state [gets]])
  => (require [hymn.macros [do-monad-return]])
  => (.run (do-monad-return [a (gets first)] a) [1 2 3])
  (1, [1, 2, 3])


Operations
^^^^^^^^^^

Use :func:`get-state` to fetch the shared state, :code:`<-state` is an alias of
:func:`get-state`

.. code-block:: clojure

  => (import [hymn.types.state [get-state <-state]])
  => (.run get-state [1 2 3])
  ([1, 2, 3], [1, 2, 3])
  => (.run <-state [1 2 3])
  ([1, 2, 3], [1, 2, 3])

Use :func:`lookup` to get the value of key in the shared state, :code:`<-` is
an alias of :func:`lookup`

.. code-block:: clojure

  => (import [hymn.types.state [lookup <-]])
  => (.run (lookup 1) [1 2 3])
  (2, [1, 2, 3])
  => (.evaluate (lookup 1) [1 2 3])
  2
  => (.evaluate (lookup 'a) {'a 1 'b 2})
  1
  => (.run (<- 1) [1 2 3])
  (2, [1, 2, 3])
  => (.evaluate (<- 1) [1 2 3])
  2
  => (.evaluate (<- 'a) {'a 1 'b 2})
  1

:func:`gets` uses a function to fetch value of shared state

.. code-block:: clojure

  => (import [hymn.types.state [gets]])
  => (.run (gets first) [1 2 3])
  (1, [1, 2, 3])
  => (.run (gets second) [1 2 3])
  (2, [1, 2, 3])
  => (.run (gets len) [1 2 3])
  (3, [1, 2, 3])

:func:`modify` changes the current state with a function

.. code-block:: clojure

  => (import [hymn.types.state [modify]])
  => (.run (modify inc) 41)
  (41, 42)
  => (.evaluate (modify inc) 41)
  41
  => (.execute (modify inc) 41)
  42
  => (.run (modify str) 42)
  (42, '42')

:func:`set-state` replaces the current state and returns the previous one,
:data:`state<-` is an alias of :func:`set-state`

.. code-block:: clojure

  => (import [hymn.types.state [set-state state<-]])
  => (.run (set-state 42) 1)
  (1, 42)
  => (.run (state<- 42) 1)
  (1, 42)

:func:`set-value` sets the value in the state with the key

.. code-block:: clojure

  => (import [hymn.types.state [set-value]])
  => (.run (set-value 2 42) [1 2 3])
  ([1, 2, 3], [1, 2, 42])

:func:`set-values` sets multiple values at once

.. code-block::

  => (import [hymn.types.state [set-values]])
  => (.run (set-values :a 1 :b 2) {})
  ({}, {'a': 1, 'b': 2})

:func:`update` changes the value with the key by applying a function to it

.. code-block:: clojure

  => (import [hymn.types.state [update]])
  => (.run (update 0 inc) [0 1 2])
  (0, [1, 1, 2])

:func:`update-value` sets the value in the state with the key

.. code-block:: clojure

  => (import [hymn.types.state [update-value]])
  => (.run (update-value 0 42) [0 1 2])
  (0, [42, 1, 2])
