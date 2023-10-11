The State Monad
===============

.. module:: hymn.types.state

.. class:: State

  the state monad

  computation with a shared state

  .. method:: bind(self, f)

    the bind operation of :class:`State`

    use the final state of this computation as the initial state of the
    second"

  .. method:: unit(cls, a)
    :classmethod:

    the unit of state monad

  .. method:: evaluate(self, s)

    evaluate state monad with initial state and return the result

  .. method:: execute(self, s)

    execute state monad with initial state, return the final state

  .. method:: run(self, s)

    evaluate state monad with initial state, return result and state

.. function:: get_state

  return the current state

.. function:: lookup(key)

  return a monadic function that lookup the vaule with key in the state

.. function:: gets(f)

  gets specific component of the state, using a projection function :code:`f`

.. function:: modify(f)

  maps the current state with `f` to a new state inside a state monad

.. function:: set_state(s)

  replace the current state and return the previous one

.. function:: set_value(key, value)

  return a monadic function that set the vaule of key in the state

.. function:: set_values(**values)

   return a monadic function that set the vaules of keys in the state

.. function:: update(key, f)

  return a monadic function that update the vaule by f with key in the state

.. function:: update_value(key, value)

  return a monadic function that update the vaule with key in the state


Hy Specific API
---------------

.. class:: state-m

  alias of :class:`State`

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

  => (import hymn.types.state [gets])
  => (require hymn.macros [do-monad-return])
  => (.run (do-monad-return [a (gets (fn [x] (get x 0)))] a) [1 2 3])
  #(1 [1 2 3])


Operations
^^^^^^^^^^

Use :func:`get-state` to fetch the shared state, :code:`<-state` is an alias of
:func:`get-state`

.. code-block:: clojure

  => (import hymn.types.state [get-state <-state])
  => (.run get-state [1 2 3])
  #([1 2 3] [1 2 3])
  => (.run <-state [1 2 3])
  #([1 2 3] [1 2 3])

Use :func:`lookup` to get the value of key in the shared state, :code:`<-` is
an alias of :func:`lookup`

.. code-block:: clojure

  => (import hymn.types.state [lookup <-])
  => (.run (lookup 1) [1 2 3])
  #(2 [1 2 3])
  => (.evaluate (lookup 1) [1 2 3])
  2
  => (.evaluate (lookup 'a) {'a 1 'b 2})
  1
  => (.run (<- 1) [1 2 3])
  #(2 [1 2 3])
  => (.evaluate (<- 1) [1 2 3])
  2
  => (.evaluate (<- 'a) {'a 1 'b 2})
  1

:func:`gets` uses a function to fetch value of shared state

.. code-block:: clojure

  => (import hymn.types.state [gets])
  => (.run (gets (fn [x] (get x 0))) [1 2 3])
  #(1 [1 2 3])
  => (.run (gets (fn [x] (get x 1))) [1 2 3])
  #(2 [1 2 3])
  => (.run (gets len) [1 2 3])
  #(3 [1 2 3])

:func:`modify` changes the current state with a function

.. code-block:: clojure

  => (import hymn.types.state [modify])
  => (.run (modify (fn [x] (+ x 1))) 41)
  #(41 42)
  => (.evaluate (modify (fn [x] (+ x 1))) 41)
  41
  => (.execute (modify (fn [x] (+ x 1))) 41)
  42
  => (.run (modify str) 42)
  #(42 "42")

:func:`set-state` replaces the current state and returns the previous one,
:data:`state<-` is an alias of :func:`set-state`

.. code-block:: clojure

  => (import hymn.types.state [set-state state<-])
  => (.run (set-state 42) 1)
  #(1 42)
  => (.run (state<- 42) 1)
  #(1 42)

:func:`set-value` sets the value in the state with the key

.. code-block:: clojure

  => (import hymn.types.state [set-value])
  => (.run (set-value 2 42) [1 2 3])
  #([1 2 3] [1 2 42])

:func:`set-values` sets multiple values at once

.. code-block::

  => (import hymn.types.state [set-values])
  => (.run (set-values :a 1 :b 2) {})
  #({} {"a" 1  "b" 2})

:func:`update` changes the value with the key by applying a function to it

.. code-block:: clojure

  => (import hymn.types.state [update])
  => (.run (update 0 (fn [x] (+ x 1))) [0 1 2])
  #(0 [1 1 2])

:func:`update-value` sets the value in the state with the key

.. code-block:: clojure

  => (import hymn.types.state [update-value])
  => (.run (update-value 0 42) [0 1 2])
  #(0 [42 1 2])
