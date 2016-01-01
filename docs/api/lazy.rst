The Lazy Monad
==============

.. automodule:: hymn.types.lazy
  :members:
  :show-inheritance:

.. function:: unit

  alias of :meth:`Lazy.unit`

.. function:: evaluate

  alias of :meth:`Lazy.evaluate`


Hy Specific API
---------------

.. class:: lazy-m

  alias of :class:`Lazy`


Macro
^^^^^

.. function:: lazy [&rest exprs]

  create a :class:`Lazy` from expressions, the expressions will not be
  evaluated until being forced by :func:`force` or :meth:`~Lazy.evaluate`


Function
^^^^^^^^

.. function:: lazy?

  alias of :func:`is_lazy`


Examples
--------


Do Notation
^^^^^^^^^^^

.. code-block:: clojure

  => (require hymn.dsl)
  => (require hymn.types.lazy)
  => (def two (do-monad [x (lazy (print "evaluate two") 2)] x))
  => two
  Lazy(_)
  => (.evaluate two)
  evaluate two
  2


Operations
^^^^^^^^^^

Use macro :func:`lazy` to create deferred computation from expressions, the
computation will not be evaluated until asked explicitly

.. code-block:: clojure

  => (require hymn.dsl)
  => (require hymn.types.lazy)
  => (def answer (lazy (print "the answer is ...") 42))
  => answer
  Lazy(_)
  => (.evaluate answer)
  the answer is ...
  42
  => (.evaluate answer)
  42

Deferred computation can also be created with expressions wrapped in a function

.. code-block:: clojure

  => (import [hymn.types.lazy [lazy-m]])
  => (def a (lazy-m (fn [] (print "^o^") 42)))
  => (.evaluate a)
  ^o^
  42

Use :meth:`~Lazy.evaluate` to evaluate the computation, the result will be
cached

.. code-block:: clojure

  => (require hymn.types.lazy)
  => (def who (lazy (input "enter your name? ")))
  => who
  Lazy(_)
  => (.evaluate who)
  enter your name? Marvin
  'Marvin'
  => who
  Lazy('Marvin')
  => (import [hymn.operations [lift]])
  => (def m+ (lift +))
  => (def x (lazy (print "get x") 2))
  => x
  Lazy(_)
  => (def x3 (m+ x x x))
  => x3
  Lazy(_)
  => (.evaluate x3)
  get x
  6
  => x
  Lazy(2)
  => x3
  Lazy(6)

Use :func:`force` to evaluate :class:`Lazy` as well as other values

.. code-block:: clojure

  => (require hymn.types.lazy)
  => (import [hymn.types.lazy [force]])
  => (force (lazy (print "yes") 1))
  yes
  1
  => (force 1)
  1
  => (def a (lazy (print "Stat!") (+ 1 2 3)))
  => a
  Lazy(_)
  => (force a)
  Stat!
  6
  => a
  Lazy(6)

:func:`lazy?` returns :code:`True` if the object is a :class:`Lazy` value

.. code-block:: clojure

  => (import [hymn.types.lazy [lazy-m lazy?]])
  => (lazy? 1)
  False
  => (lazy? (lazy-m.unit 1))
  True