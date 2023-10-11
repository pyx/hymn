The Lazy Monad
==============

.. module:: hymn.types.lazy

.. class:: Lazy

  the lazy monad

  lazy computation as monad


  .. method:: bind(self, f)

    the bind operator of :class:`Lazy`

  .. method:: unit(cls, value)
    :classmethod:

    the unit of lazy monad

  .. method:: evaluate(self)

    evaluate the lazy monad

  .. property:: evaluated

    return :code:`True` if this computation is evaluated

.. function:: force(m)

  force the deferred computation :code:`m` if it is a :class:`Lazy`, act as
  function :code:`identity` otherwise, return the result

.. function:: is_lazy(m)

  return :code:`True` if :code:`v` is a :class:`Lazy`


Hy Specific API
---------------

.. class:: lazy-m

  alias of :class:`Lazy`

.. function:: lazy?

  alias of :meth:`is_lazy`


Macro
^^^^^

.. function:: lazy [#* exprs]

  create a :class:`Lazy` from expressions, the expressions will not be
  evaluated until being forced by :func:`force` or :meth:`~Lazy.evaluate`



Examples
--------


Do Notation
^^^^^^^^^^^

.. code-block:: clojure

  => (require hymn.macros [do-monad-return])
  => (require hymn.types.lazy [lazy])
  => (setv two (do-monad-return [x (lazy (print "evaluate two") 2)] x))
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

  => (require hymn.types.lazy [lazy])
  => (setv answer (lazy (print "the answer is ...") 42))
  => answer
  Lazy(_)
  => (.evaluate answer)
  the answer is ...
  42
  => (.evaluate answer)
  42

Deferred computation can also be created with expressions wrapped in a
function

.. code-block:: clojure

  => (import hymn.types.lazy [lazy-m])
  => (setv a (lazy-m (fn [] (print "^o^") 42)))
  => (.evaluate a)
  ^o^
  42

Use :meth:`~Lazy.evaluate` to evaluate the computation, the result will be
cached

.. code-block:: clojure

  => (require hymn.types.lazy [lazy])
  => (setv who (lazy (input "enter your name? ")))
  => who
  Lazy(_)
  => (.evaluate who)
  enter your name? Marvin
  "Marvin"
  => who
  Lazy('Marvin')
  => (import hymn.operations [lift])
  => (import hy.pyops [+])
  => (setv m+ (lift +))
  => (setv x (lazy (print "get x") 2))
  => x
  Lazy(_)
  => (setv x3 (m+ x x x))
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

  => (import hymn.types.lazy [force])
  => (require hymn.types.lazy [lazy])
  => (force (lazy (print "yes") 1))
  yes
  1
  => (force 1)
  1
  => (setv a (lazy (print "Stat!") (+ 1 2 3)))
  => a
  Lazy(_)
  => (force a)
  Stat!
  6
  => a
  Lazy(6)

:func:`lazy?` returns :code:`True` if the object is a :class:`Lazy` value

.. code-block:: clojure

  => (import hymn.types.lazy [lazy?])
  => (require hymn.types.lazy [lazy])
  => (lazy? 1)
  False
  => (lazy? (lazy 1))
  True
