The Either Monad
================

.. automodule:: hymn.types.either
  :members:
  :show-inheritance:

.. autodata:: zero

.. function:: to_either
  :noindex:

  alias of :meth:`~Either.from_value`


Hy Specific API
---------------

.. class:: either-m

  alias of :class:`Either`


Tag Macro
^^^^^^^^^

.. function:: | [f]

  turn :code:`f` into monadic function with :func:`failsafe`


Functions
^^^^^^^^^

.. function:: ->either
.. function:: to-either

  alias of :func:`Either.from_value`

.. function:: left?

  alias of :func:`is_left`

.. function:: right?

  alias of :func:`is_right`


Examples
--------


Comparison
^^^^^^^^^^

Either are comparable if the wrapped values are comparable. :class:`Right` is
greater than :data:`Left` in any case.

.. code-block:: clojure

  => (import [hymn.types.either [Left Right]])
  => (> (Right 2) (Right 1))
  True
  => (< (Left 2) (Left 1))
  False
  => (> (Left 2) (Right 1))
  False


Do Notation
^^^^^^^^^^^

.. code-block:: clojure

  => (import [hymn.types.either [Left Right]])
  => (require [hymn.macros [do-monad-return]])
  => (do-monad-return [a (Right 1) b (Right 2)] (+ a b))
  Right(3)
  => (do-monad-return [a (Left 1) b (Right 2)] (+ a b))
  Left(1)


Do Notation with :when
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: clojure

  => (import [hymn.types.either [either-m]])
  => (require [hymn.macros [do-monad-with]])
  => (defn safe-div [a b]
  ...    (do-monad-with either-m [:when (not (zero? b))] (/ a b)))
  => (safe-div 1 2)
  Right(0.5)
  => (safe-div 1 0)
  Left('unknown error')


Operations
^^^^^^^^^^

Use :code:`->either` to create an :class:`Either` from a value

.. code-block:: clojure

  => (import [hymn.types.either [->either]])
  => (->either 42)
  Right(42)
  => (->either None)
  Left(None)

Use :func:`left?` and :func:`right?` to test the type

.. code-block:: clojure

  => (import [hymn.types.either [Left Right left? right?]])
  => (right? (Right 42))
  True
  => (left? (Left None))
  True

:func:`either` applies function to value in the monad depending on the type

.. code-block:: clojure

  => (import [hymn.types.either [Left Right either]])
  => (either print inc (Left 1))
  1
  => (either print inc (Right 1))
  2

:func:`failsafe` turns function into monadic one

.. code-block:: clojure

  => (import [hymn.types.either [failsafe]])
  => (with-decorator failsafe (defn add1 [n] (inc (int n))))
  => (add1 "41")
  Right(42)
  => (add1 "nan")
  Left(ValueError("invalid literal for int() with base 10: 'nan'",))
  => (setv safe-div (failsafe /))
  => (safe-div 1 2)
  Right(0.5)
  => (safe-div 1 0)
  Left(ZeroDivisionError('division by zero',))


Tag Macro
^^^^^^^^^

.. code-block:: clojure

  => (require [hymn.types.either [|]])
  => (#| int "42")
  Right(42)
  => (#| int "nan")
  Left(ValueError("invalid literal for int() with base 10: 'nan'",))
  => (setv safe-div #| /)
  => (safe-div 1 2)
  Right(0.5)
  => (safe-div 1 0)
  Left(ZeroDivisionError('division by zero',))
