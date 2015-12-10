;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2015, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hymn.types.list - the list monad"

(import
  [itertools [chain]]
  [hymn.types.monadplus [MonadPlus]]
  [hymn.utils [CachedSequence]])

(defreader * [seq]
  (with-gensyms [List]
    `(do (import [hymn.types.list [List :as ~List]]) (~List ~seq))))

(defclass -Zero [object]
  "descriptor that returns an empty List"
  [[--get-- (fn [self instance cls] (cls []))]])

(defclass List [MonadPlus]
  "the list monad

  nondeterministic computation"
  [[--init-- (fn [self value] (setv self.value (CachedSequence value)) nil)]
   [--iter-- (fn [self] (iter self.value))]
   [--len-- (fn [self] (len self.value))]
   [fmap (fn [self f]
           "return list obtained by applying ``f`` to each element of the list"
           (List (map f self.value)))]
   [join (fn [self]
           "join of list monad, concatenate list of list"
           (List (chain.from-iterable self)))]
   [plus (fn [self other]
           "concatenate two list"
           (List (chain self other)))]
   [unit (with-decorator classmethod (fn [cls value] (cls [value])))]
   [zero (-Zero)]])

;;; alias
(def list-m List)
(def unit List.unit)
(def zero List.zero)

(defn fmap [f iterable]
  "``fmap`` works like the builtin ``map``, but return a :class:`List` instead
  of ``list``"
  (list-m (map f iterable)))
