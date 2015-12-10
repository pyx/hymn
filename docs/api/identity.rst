The Identity Monad
==================

.. automodule:: hymn.types.identity
  :members:
  :show-inheritance:

.. data:: unit

  the unit of identity monad


Hy Specific API
---------------

.. class:: identity-m

  alias of :class:`Identity`


Examples
--------

.. code-block:: clojure

  => (require hymn.dsl)
  => (import [hymn.types.identity [identity-m]])
  => (do-monad [a (identity-m.unit 1) b (identity-m.unit 2)] (+ a b))
  Identity(3)

Identity monad is comparable as long as what's wrapped inside are comparable.

.. code-block:: clojure

  => (> (identity-m.unit 2) (identity-m.unit 1))
  True
  => (= (identity-m.unit 42) (identity-m.unit 42))
  True
