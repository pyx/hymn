The Either Monad
================

.. module:: hymn.types.either

.. class:: Either

  the either monad

  computation with two possibilities

  .. method:: bind(self, f)

    the bind operation of :class:`Either`

    apply function to the value if and only if this is a :class:`Right`.

  .. method:: plus(self, other)

  .. method:: from_value(cls, value)

    wrap :code:`value` in an :class:`Either` monad

    return a :class:`Right` if the value is evaluated as true.
    :class:`Left` otherwise.

.. class:: Left

   left of :class:`Either`

.. class:: Right

   right of :class:`Either`

.. function:: is_left(m)

  return :code:`True` if :code:`m` is a :class:`Left`

.. function:: is_right(m)

  return :code:`True` if :code:`m` is a :class:`Right`

.. function:: either(handle_left, handle_right m)

  case analysis for :class:`Either`

  apply either :code:`handle-left` or :code:`handle-right` to :code:`m`
  depending on the type of it,  raise :code:`TypeError` if :code:`m` is not an
  :class:`Either`

.. decorator:: failsafe(func)

  decorator to turn func into monadic function of :class:`Either` monad

.. function:: to_either

  alias of :meth:`~Either.from_value`


Hy Specific API
---------------

.. class:: either-m

  alias of :class:`Either`

.. function:: ->either

  alias of :meth:`~Either.from_value`

.. function:: left?

  alias of :func:`is_left`

.. function:: right?

  alias of :func:`is_right`


Reader Macro
^^^^^^^^^^^^

.. function:: | [f]

  turn :code:`f` into monadic function with :func:`failsafe`


Examples
--------


Comparison
^^^^^^^^^^

Either are comparable if the wrapped values are comparable. :class:`Right` is
greater than :data:`Left` in any case.

.. code-block:: clojure

  => (import hymn.types.either [Left Right])
  => (> (Right 2) (Right 1))
  True
  => (< (Left 2) (Left 1))
  False
  => (> (Left 2) (Right 1))
  False


Do Notation
^^^^^^^^^^^

.. code-block:: clojure

  => (import hymn.types.either [Left Right])
  => (require hymn.macros [do-monad-return])
  => (do-monad-return [a (Right 1) b (Right 2)] (+ a b))
  Right(3)
  => (do-monad-return [a (Left 1) b (Right 2)] (+ a b))
  Left(1)


Do Notation with :when
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: clojure

  => (import hymn.types.either [either-m])
  => (require hymn.macros [do-monad-with])
  => (defn safe-div [a b]
  ...    (do-monad-with either-m [:when (not (= 0 b))] (/ a b)))
  => (safe-div 1 2)
  Right(0.5)
  => (safe-div 1 0)
  Left('unknown error')


Operations
^^^^^^^^^^

Use :code:`->either` to create an :class:`Either` from a value

.. code-block:: clojure

  => (import hymn.types.either [->either])
  => (->either 42)
  Right(42)
  => (->either None)
  Left(None)

Use :func:`left?` and :func:`right?` to test the type

.. code-block:: clojure

  => (import hymn.types.either [Left Right left? right?])
  => (right? (Right 42))
  True
  => (left? (Left None))
  True

:func:`either` applies function to value in the monad depending on the type

.. code-block:: clojure

  => (import hymn.types.either [Left Right either])
  => (either print (fn [x] (+ x 1)) (Left 1))
  1
  => (either print (fn [x] (+ x 1)) (Right 1))
  2

:func:`failsafe` turns function into monadic one

.. code-block:: clojure

  => (import hymn.types.either [failsafe])
  => (defn [failsafe] add1 [n] (+ 1 (int n)))
  => (add1 "41")
  Right(42)
  => (add1 "nan")
  Left(ValueError("invalid literal for int() with base 10: 'nan'"))
  => (import hy.pyops [/])
  => (setv safe-div (failsafe /))
  => (safe-div 1 2)
  Right(0.5)
  => (safe-div 1 0)
  Left(ZeroDivisionError('division by zero'))


Reader Macro
^^^^^^^^^^^^

.. code-block:: clojure

  => (require hymn.types.either :readers [|])
  => (#| int "42")
  Right(42)
  => (#| int "nan")
  Left(ValueError("invalid literal for int() with base 10: 'nan'"))
  => (import hy.pyops [/])
  => (setv safe-div #| /)
  => (safe-div 1 2)
  Right(0.5)
  => (safe-div 1 0)
  Left(ZeroDivisionError('division by zero'))
