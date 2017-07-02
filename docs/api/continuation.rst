The Continuation Monad
======================

.. automodule:: hymn.types.continuation
  :members:
  :show-inheritance:

.. function:: unit

  alias of :meth:`Continuation.unit`

.. function:: run

  alias of :meth:`Continuation.run`


Hy Specific API
---------------

.. class:: cont-m
.. class:: continuation-m

  alias of :class:`Continuation`


Sharp Macro
^^^^^^^^^^^

.. function:: < [v]

  create a :class:`Continuation` of :code:`v`


Functions
^^^^^^^^^

.. function:: call-cc

  alias of :func:`call_cc`


Examples
--------


Do Notation
^^^^^^^^^^^

.. code-block:: clojure

  => (import [hymn.types.continuation [cont-m]])
  => (require [hymn.macros [do-monad]])
  => (.run (do-monad [a (cont-m.unit 1)] (inc a)))
  2


Operations
^^^^^^^^^^

:func:`call-cc` - call with current continuation

.. code-block:: clojure

  => (import [hymn.types.continuation [call-cc cont-m]])
  => (require [hymn.macros [m-when do-monad-with]])
  => (defn search [n seq]
  ...   (call-cc
  ...     (fn [exit]
  ...       (do-monad-with cont-m
  ...         [_ (m-when (in n seq) (exit (.index seq n)))]
  ...         "not found."))))
  => (.run (search 0 [1 2 3 4 5]))
  'not found.'
  => (.run (search 0 [1 2 3 0 5]))
  3


Sharp Macro
^^^^^^^^^^^

.. code-block:: clojure

  => (require [hymn.types.continuation [<]])
  => (#<42)
  42
  => (require [hymn.macros [do-monad]])
  => (.run (do-monad [a #<25 b #<17] (+ a b)))
  42
