The Writer Monad
================

.. automodule:: hymn.types.writer
  :members:
  :show-inheritance:

.. function:: execute

  alias of :meth:`Writer.execute`

.. function:: run

  alias of :meth:`Writer.run`


Predefined Writers
------------------

.. autoclass:: ComplexWriter
.. autoclass:: DecimalWriter
.. autoclass:: FloatWriter
.. autoclass:: FractionWriter
.. autoclass:: ListWriter
.. autoclass:: IntWriter
.. autoclass:: StringWriter
.. autoclass:: TupleWriter


Hy Specific API
---------------

.. class:: writer-m

  alias of :class:`Writer`


Functions
^^^^^^^^^

.. function:: writer-with-type

  alias of :func:`writer_with_type`

.. function:: writer-with-type-of

  alias of :func:`writer_with_type_of`


Tag Macro
^^^^^^^^^

.. function:: + [w]

  create a writer that logs :code:`w`


Writers
^^^^^^^

.. class:: complex-writer-m

  alias of :class:`ComplexWriter`

.. class:: decimal-writer-m

  alias of :class:`DecimalWriter`

.. class:: float-writer-m

  alias of :class:`FloatWriter`

.. class:: fraction-writer-m

  alias of :class:`FractionWriter`

.. class:: list-writer-m

  alias of :class:`ListWriter`

.. class:: int-writer-m

  alias of :class:`IntWriter`

.. class:: string-writer-m

  alias of :class:`StringWriter`

.. class:: tuple-writer-m

  alias of :class:`TupleWriter`


Examples
--------


Do Notation
^^^^^^^^^^^

.. code-block:: clojure

  => (import [hymn.types.writer [tell]])
  => (require [hymn.macros [do-monad]])
  => (do-monad [_ (tell 1) _ (tell 2)] None)
  IntWriter((None, 3))
  => (do-monad [_ (tell "hello ") _ (tell "world!")] None)
  StrWriter((None, 'hello world!'))


Operations
^^^^^^^^^^

:func:`writer` creates a :class:`Writer`

.. code-block:: clojure

  => (import [hymn.types.writer [writer]])
  => (writer None 1)
  IntWriter((None, 1))

:func:`tell` adds message into accumulated values of writer

.. code-block:: clojure

  => (import [hymn.types.writer [tell writer]])
  => (.run (tell 1))
  (None, 1)
  => (.run (>> (writer 1 1) tell))
  (None, 2)

:func:`tell` and :func:`writer` are smart enough to create writer of
appropriate type

.. code-block:: clojure

  => (import [hymn.types.writer [tell writer]])
  => (writer None "a")
  StrWriter((None, 'a'))
  => (writer None 1)
  IntWriter((None, 1))
  => (writer None 1.0)
  FloatWriter((None, 1.0))
  => (writer None (, 1))
  TupleWriter((None, (1,)))
  => (writer None [1])
  ListWriter((None, [1]))
  => (tell "a")
  StrWriter((None, 'a'))
  => (tell 1)
  IntWriter((None, 1))
  => (tell 1.0)
  FloatWriter((None, 1.0))
  => (tell (, 1))
  TupleWriter((None, (1,)))
  => (tell [1])
  ListWriter((None, [1]))

Use :func:`listen` to get the value of the writer

.. code-block:: clojure

  => (import [hymn.types.writer [listen writer]])
  => (listen (writer "value" 42))
  IntWriter((('value', 42), 42))

Use :func:`censor` to apply function to the output

.. code-block:: clojure

  => (import [hymn.types.writer [censor tell]])
  => (require [hymn.macros [do-monad]])
  => (setv logs (do-monad [_ (tell [1]) _ (tell [2]) _ (tell [3])] None))
  => (.execute logs)
  [1, 2, 3]
  => (.execute (censor sum logs))
  6


Tag Macro
^^^^^^^^^

.. code-block:: clojure

  => (require [hymn.types.writer [+]])
  => ;; tag macro + works like tell
  => #+ 1
  IntWriter((None, 1))
  => (.execute #+ 1)
  1
  => (require [hymn.macros [do-monad]])
  => (do-monad [_ #+ 1 _ #+ 2 _ #+ 4] 42)
  IntWriter((42, 7))
