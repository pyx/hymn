The Monad Class
===============

.. module:: hymn.types.monad

.. class:: Monad

  the monad class

  Implements bind operator :code:`>>` and inverted bind operator :code:`<<` as
  syntactic sugar.  It is equivalent to :code:`(>>=)` and :code:`(=<<)` in
  haskell, not to be confused with :code:`(>>)` and :code:`(<<)` in haskell.

  As python treats assignments as statements, there is no way we can overload
  :code:`>>=` as a chainable bind, be it directly overloaded through
  :code:`__irshift__`, or derived by python itself through :code:`__rshift__`.

  The default implementations of :meth:`bind`, :meth:`fmap` and :meth:`join`
  are mutual recursive, subclasses should at least either override
  :meth:`bind`, or :meth:`fmap` and :meth:`join`, or all of them for better
  performance.

  .. method:: bind(self, f)

    the bind operation

    :code:`f` is a function that maps from the underlying value to a
    monadic type, something like signature :code:`f :: a -> M a` in
    haskell's term.

    The default implementation defines :meth:`bind` in terms of
    :meth:`fmap` and :meth:`join`.


  .. method:: fmap(self, f)

    the fmap operation

    The default implementation defines :meth:`fmap` in terms of
    :meth:`bind` and :meth:`.unit`.

  .. method:: join(self)

    the join operation

    The default implementation defines :meth:`join` in terms of
    :meth:`bind` and :code:`identity` function.

  .. method:: monadic(cls, f)
    :classmethod:

    decorator that turn :code:`f` into monadic function of the monad

  .. method:: unit(cls, value)
    :classmethod:

    the unit of monad
