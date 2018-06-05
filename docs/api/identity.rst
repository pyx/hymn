The Identity Monad
==================

.. automodule:: hymn.types.identity
  :members:
  :show-inheritance:

.. function:: unit

  alias of :meth:`Identity.unit`


Hy Specific API
---------------

.. class:: identity-m

  alias of :class:`Identity`


Examples
--------

.. code-block:: clojure

  => (import [hymn.types.identity [identity-m]])
  => (require [hymn.macros [do-monad-return]])
  => (do-monad-return [a (identity-m.unit 1) b (identity-m.unit 2)] (+ a b))
  Identity(3)

Identity monad is comparable as long as what's wrapped inside are comparable.

.. code-block:: clojure

  => (import [hymn.types.identity [identity-m]])
  => (> (identity-m.unit 2) (identity-m.unit 1))
  True
  => (= (identity-m.unit 42) (identity-m.unit 42))
  True
