;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2017, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hymn.types.list - the list monad"

(import
  [itertools [chain]]
  [hymn.types.monadplus [MonadPlus]]
  [hymn.types.monoid [Monoid]]
  [hymn.utils [CachedSequence]])

(deftag ~ [seq]
  (with-gensyms [List]
    `(do (import [hymn.types.list [List :as ~List]]) (~List ~seq))))

(defclass -Zero [object]
  "descriptor that returns an empty List"
  (defn --get-- [self instance cls] (cls [])))

(defclass List [MonadPlus Monoid]
  "the list monad

  nondeterministic computation"
  (defn --init-- [self value] (setv self.value (CachedSequence value)))

  (defn --iter-- [self] (iter self.value))

  (defn --len-- [self] (len self.value))

  (defn fmap [self f]
    "return list obtained by applying :code:`f` to each element of the list"
    ((type self) (map f self.value)))

  (defn join [self]
    "join of list monad, concatenate list of list"
    ((type self) (chain.from-iterable self)))

  (defn append [self other]
    "the append operation of :class:`List`"
    ((type self) (chain self other)))

  (with-decorator classmethod
    (defn concat [cls list-of-lists]
      "the concat operation of :class:`List`"
      (cls (chain.from-iterable list-of-lists))))

  (defn plus [self other] "concatenate two lists" (.append self other))

  (with-decorator classmethod
    (defn unit [cls &rest values]
      "the unit, create a :class:`List` from :code:`values`"
      (cls values)))

  (setv zero (-Zero))
  (setv empty zero))

;;; alias
(setv list-m List)
(setv unit List.unit)
(setv zero List.zero)

(defn fmap [f iterable]
  ":code:`fmap` works like the builtin :code:`map`, but return a :class:`List`
  instead of :code:`list`"
  (list-m (map f iterable)))
