Utility Functions and Types
===========================

.. module:: hymn.utils

.. note:: Functions and classes in this module are for internal usage only.

Classes
-------

.. class:: CachedSequence

  sequence wrapper that is lazy while keeps the items"


Functions
---------

.. function:: thread_first(sym, expr)

   insert symbol into expression as second item

.. function:: thread_last(sym, expr)

  insert symbol into expression as last item

.. function:: thread_bindings(thread_fn, init_value, exprs)

  create a stream of symbol and expressions to be used in threading macros


.. function:: constantly(c)

   constant function

.. function:: compose(f, g)

  function composition

.. function:: identity(x)

  identity function

.. function:: repeatedly(f)

  repeatedly apply function f
