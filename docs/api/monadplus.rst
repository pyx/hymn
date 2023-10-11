The MonadPlus Class
===================

.. module:: hymn.types.monadplus

.. class:: MonadPlus

  the monadplus class

  Monads that also support choice and failure.

  .. method:: plus(self, other)

    the associative operation

  .. property:: zero

    the identity of :meth:`plus`.

    It should satisfy the following law, left zero
    (notice the bind operator is haskell's :code:`>>=` here)::

      zero >>= f = zero
