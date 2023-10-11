The Monoid Class
================

.. module:: hymn.types.monoid

.. class:: Monoid

  the monoid class

  types with an associative binary operation that has an identity

  .. property:: empty

    the identity of :meth:`append`

  .. method:: append(self, other)

    an associative operation for monoid

  .. method:: concat(cls, seq)
    :classmethod:

    fold a list using the monoid

.. function:: append

  the associative operation of monoid


Hy Specific API
---------------


Functions
^^^^^^^^^

.. function:: <>

  alias of :func:`append`


Examples
--------

:func:`append` adds up the values, while handling :attr:`~Monoid.empty`
gracefully, :obj:`<>` is an alias of :func:`append`

.. code-block:: clojure

  => (import hymn.types.maybe [Just Nothing])
  => (import hymn.types.monoid [<> append])
  => (append (Just "Cuddles ") Nothing (Just "the ") Nothing (Just "Hacker"))
  Just('Cuddles the Hacker')
  => (<> (Just "Cuddles ") Nothing (Just "the ") Nothing (Just "Hacker"))
  Just('Cuddles the Hacker')
