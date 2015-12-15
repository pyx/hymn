The Monoid Class
================

.. automodule:: hymn.types.monoid
  :members: Monoid, append
  :show-inheritance:


Hy Specific API
---------------


Functions
^^^^^^^^^

.. function:: <>

  alias of :func:`append`


Examples
--------

:func:`append` adds up the values, while handling :attr:`~Monoid.empty`
gracefully, :data:`<>` is an alias of :func:`append`

.. code-block:: clojure

  => (import [hymn.types.maybe [Just Nothing]])
  => (import [hymn.types.monoid [<> append]])
  => (append (Just "Cuddles ") Nothing (Just "the ") Nothing (Just "Hacker"))
  Just('Cuddles the Hacker')
  => (<> (Just "Cuddles ") Nothing (Just "the ") Nothing (Just "Hacker"))
  Just('Cuddles the Hacker')
