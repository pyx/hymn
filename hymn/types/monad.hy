;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2015, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hymn.types.monad - base monad class"

(import
  [hymn.utils [compose]])

(defclass Monad [object]
  "the monad class

  Implements bind operator ``>>`` and inverted bind operator ``<<`` as
  syntactic sugar.  It is equivalent to ``(>>=)`` and ``(=<<)`` in haskell,
  not to be confused with ``(>>)`` and ``(<<)`` in haskell.

  As python treats assignments as statements, there is no way we can
  overload ``>>=`` as a chainable bind, be it directly overloaded through
  ``__irshift__``, or derived by python itself through ``__rshift__``.

  The default implementations of ``bind``, ``fmap`` and ``join`` are mutual
  recursive, subclasses should at least either override ``bind``, or
  ``fmap`` and ``join``, or all of them for better performance."
  [[--init-- (fn [self value] (def self.value value) nil)]
   [--repr-- (fn [self]
               (.format "{}({!r})" (. (type self) --name--) self.value))]
   [--rshift-- (fn [self f] (.bind self f))]
   [--rlshift-- --rshift--]
   [bind (fn [self f]
           "the bind operation

           ``f`` is a function that maps from the
           underlying value to a monadic type, something like signature ``f ::
           a -> M a`` in haskell's term.

           The default implementation defines ``bind`` in terms of ``fmap``
           and ``join``."
           (.join (.fmap self f)))]
   [fmap (fn [self f]
           "the fmap operation

           The default implementation defines ``fmap`` in terms of ``bind``
           and ``unit``."
           (.bind self (self.monadic f)))]
   [join (fn [self]
           "the join operation

           The default implementation defines ``join`` in terms of ``bind``
           and ``identity`` function."
           (.bind self identity))]
   [monadic (with-decorator classmethod (fn [cls f]
                                          "decorator that turn ``f`` into
                                          monadic function of the monad"
                                          (compose cls.unit f)))]
   [unit (with-decorator classmethod (fn [cls value]
                                       "the ``unit`` of monad"
                                       (cls value)))]])
