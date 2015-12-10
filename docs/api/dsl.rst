DSL
===

The module :mod:`hymn.dsl` provides types and functions from other modules of
this package, so that they can be imported all at once easily.

Python

.. code-block:: python

  from hymn.dsl import *

Hy

.. code-block:: clojure

  (import [hymn.dsl [*]])

This module also provides all the macros defined in other modules,

.. code-block:: clojure

  (require hymn.dsl)

is all you need to use any macro defined in ``Hymn``

.. note::

  Some of the function are renamed to more descriptive one to avoid name clash,
  examples are :func:`hymn.types.reader.lookup` and
  :func:`hymn.types.state.lookup`

The entire source code of this module is listed here for reference:

.. literalinclude:: ../../hymn/dsl.hy
  :language: lisp
  :lines: 7-
