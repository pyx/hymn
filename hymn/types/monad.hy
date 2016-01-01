;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2016, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hymn.types.monad - base monad class"

(import
  [hymn.utils [compose]])

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
  [[--init-- (fn [self value] (def self.value value) nil)]
   [--repr-- (fn [self]
               (.format "{}({!r})" (. (type self) --name--) self.value))]
   [--rshift-- (fn [self f] (.bind self f))]
   [--rlshift-- --rshift--]
   [bind (fn [self f]
           "the bind operation

           :code:`f` is a function that maps from the underlying value to a
           monadic type, something like signature :code:`f :: a -> M a` in
           haskell's term.

           The default implementation defines :meth:`bind` in terms of
           :meth:`fmap` and :meth:`join`."
           (.join (.fmap self f)))]
   [fmap (fn [self f]
           "the fmap operation

           The default implementation defines :meth:`fmap` in terms of
           :meth:`bind` and :meth:`unit`."
           (.bind self (self.monadic f)))]
   [join (fn [self]
           "the join operation

           The default implementation defines :meth:`join` in terms of
           :meth:`bind` and :code:`identity` function."
           (.bind self identity))]
   [monadic (with-decorator classmethod (fn [cls f]
                                          "decorator that turn :code:`f` into
                                          monadic function of the monad"
                                          (compose cls.unit f)))]
   [unit (with-decorator classmethod (fn [cls value]
                                       "the unit of monad"
                                       (cls value)))]])
