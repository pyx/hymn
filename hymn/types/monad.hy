;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.
"hymn.types.monad - base monad class"

(defclass Monad [object]
  "the monad class

  Implements bind operator :code:`>>` and inverted bind operator :code:`<<` as
  syntactic sugar.  It is equivalent to :code:`(>>=)` and :code:`(=<<)` in
  haskell, not to be confused with :code:`(>>)` and :code:`(<<)` in haskell.

  As python treats assignments as statements, there is no way we can overload
  :code:`>>=` as a chainable bind, be it directly overloaded through
  :code:`__irshift__`, or derived by python itself through :code:`__rshift__`.

  The default implementations of :meth:`bind`, :meth:`fmap` and :meth:`join`
  are mutual recursive, subclasses should at least either override
  :meth:`bind`, or :meth:`fmap` and :meth:`join`, or all of them for better
  performance."
  (defn __init__ [self value] (setv self.value value))

  (defn __repr__ [self]
    (.format "{}({!r})" (name (type self)) self.value))

  (defn __rshift__ [self f] (.bind self f))

  (setv __rlshift__ __rshift__)

  (defn bind [self f]
    "the bind operation

    :code:`f` is a function that maps from the underlying value to a
    monadic type, something like signature :code:`f :: a -> M a` in
    haskell's term.

    The default implementation defines :meth:`bind` in terms of
    :meth:`fmap` and :meth:`join`."
    (.join (.fmap self f)))

  (defn fmap [self f]
    "the fmap operation

    The default implementation defines :meth:`fmap` in terms of
    :meth:`bind` and :meth:`unit`."
    (.bind self (self.monadic f)))

  (defn join [self]
    "the join operation

    The default implementation defines :meth:`join` in terms of
    :meth:`bind` and :code:`identity` function."
    (.bind self identity))

  (with-decorator classmethod
    (defn monadic [cls f]
      "decorator that turn :code:`f` into monadic function of the monad"
      (comp cls.unit f)))

  (with-decorator classmethod
    (defn unit [cls value] "the unit of monad" (cls value))))
