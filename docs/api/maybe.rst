The Maybe Monad
===============

.. module:: hymn.types.maybe

.. class:: Maybe

  the maybe monad

  computation that may fail

  .. method:: append(self, other)

    the append operation of :class:`Maybe`

  .. method:: bind(self, f)

    the bind operation of :class:`Maybe`

    apply function to the value if and only if this is a :class:`Just`.

  .. method:: plus(self, other)

  .. method:: from_maybe(self, default)

    return the value contained in the :class:`Maybe`

    if the :class:`Maybe` is :data:`Nothing`, it returns the default values.

  .. method:: from_value(cls, value)
    :classmethod:

    wrap :code:`value` in a :class:`Maybe` monad

    return a :class:`Just` if the value is evaluated as True.
    :data:`Nothing` otherwise.

.. class:: Just

  :code:`Just` of the :class:`Maybe`

.. class:: Nothing

  the :class:`Maybe` that represents nothing, a singleton, like :code:`None`

.. function:: from_maybe

  alias of :meth:`~Maybe.from_maybe`

.. function:: to_maybe

  alias of :meth:`~Maybe.from_value`

.. function:: is_nothing

   return :code:`True` if :code:`m` is :data:`Nothing`


Hy Specific API
---------------

.. class:: maybe-m

  alias of :class:`Maybe`

.. function:: <-maybe
.. function:: from-maybe

  alias of :func:`from_maybe`

.. function:: ->maybe
.. function:: to-maybe

  alias of :func:`to_maybe`

.. function:: nothing?

  alias of :func:`is_nothing`


Reader Macro
^^^^^^^^^^^^

.. function:: ? [f]

  turn :code:`f` into monadic function with :func:`maybe`


Examples
--------


Comparison
^^^^^^^^^^

Maybes are comparable if the wrapped values are comparable. :class:`Just` is
greater than :data:`Nothing` in any case.

.. code-block:: clojure

  => (import hymn.types.maybe [Just Nothing])
  => (> (Just 2) (Just 1))
  True
  => (= (Just 1) (Just 2))
  False
  => (= (Just 2) (Just 2))
  True
  => (= Nothing Nothing)
  True
  => (= Nothing (Just 1))
  False
  => (< (Just -1) Nothing)
  False


Do Notation
^^^^^^^^^^^

.. code-block:: clojure

  => (import hymn.types.maybe [Just Nothing])
  => (require hymn.macros [do-monad-return])
  => (do-monad-return [a (Just 1) b (Just 2)] (+ a b))
  Just(3)
  => (do-monad-return [a (Just 1) b Nothing] (+ a b))
  Nothing


Do Notation with :when
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: clojure

  => (import hymn.types.maybe [maybe-m])
  => (require hymn.macros [do-monad-with])
  => (defn safe-div [a b]
  ...   (do-monad-with maybe-m [:when (not (= 0 b))] (/ a b)))
  => (safe-div 1 2)
  Just(0.5)
  => (safe-div 1 0)
  Nothing


Operations
^^^^^^^^^^

Use :func:`->maybe` to create a :class:`Maybe` from value

.. code-block:: clojure

  => (import hymn.types.maybe [->maybe])
  => (->maybe 42)
  Just(42)
  => (->maybe None)
  Nothing

:func:`nothing?` returns :code:`True` if the value is :data:`Nothing`

.. code-block:: clojure

  => (import hymn.types.maybe [Just Nothing nothing?])
  => (nothing? Nothing)
  True
  => (nothing? (Just 1))
  False

:func:`<-maybe` returns the value in the monad, or a default value if it is
:data:`Nothing`

.. code-block:: clojure

  => (import hymn.types.maybe [<-maybe ->maybe nothing?])
  => (nothing? (->maybe None))
  True
  => (setv answer (->maybe 42))
  => (setv nothing (->maybe None))
  => (<-maybe answer "not this one")
  42
  => (<-maybe nothing "I got nothing")
  "I got nothing"

:meth:`~Maybe.append` adds up the values, handling :data:`Nothing` gracefully

.. code-block:: clojure

  => (import hymn.types.maybe [Just Nothing])
  => (.append (Just 42) Nothing)
  Just(42)
  => (.append (Just 42) (Just 42))
  Just(84)
  => (.append Nothing (Just 42))
  Just(42)

:func:`maybe` turns a function into monadic one

.. code-block:: clojure

  => (import hymn.types.maybe [maybe])
  => (defn [maybe] add1 [n] (+ 1 (int n)))
  => (add1 "41")
  Just(42)
  => (add1 "nan")
  Nothing
  => (import hy.pyops [/])
  => (setv safe-div (maybe /))
  => (safe-div 1 2)
  Just(0.5)
  => (safe-div 1 0)
  Nothing


Reader Macro
^^^^^^^^^^^^

.. code-block:: clojure

  => (require hymn.types.maybe :readers [?])
  => (#? int "42")
  Just(42)
  => (#? int "not a number")
  Nothing
  => (import hy.pyops [/])
  => (setv safe-div #? /)
  => (safe-div 1 2)
  Just(0.5)
  => (safe-div 1 0)
  Nothing
