Utility Functions and Types
===========================

.. py:currentmodule:: hymn.utils


Helper Classes
--------------

.. autoclass:: CachedSequence
  :members:
  :show-inheritance:

.. autoclass:: SuppressContextManager
  :members:
  :show-inheritance:


Helper Functions
----------------

.. autofunction:: compose
.. function:: <|

  alias of :py:func:`compose`

.. note::

  :code:`.` cannot be used as *hy* and *python* already using it, :code:`<|`
  was chosen because we use :code:`|>` as alias of :py:func:`pipe` function

.. autofunction:: const
.. autofunction:: suppress
.. autofunction:: pipe
.. function:: |>

  alias of :py:func:`pipe`

.. note::

  :code:`|>` is different from the same function in *OCaml* and *F#*, which is
  more like the threading macro :code:`->>` in *hy*
