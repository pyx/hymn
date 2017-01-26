;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2017, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hymn.types.continuation - the continuation monad"

(import
  [hymn.types.monad [Monad]])

(defreader < [v]
  (with-gensyms [Continuation]
    `(do (import [hymn.types.continuation [Continuation :as ~Continuation]])
       (.unit ~Continuation ~v))))

(defclass Continuation [Monad]
  "the continuation monad"
  (defn --repr-- [self]
    (.format "{}({})" (. (type self) --name--) self.value.--name--))

  (defn --call-- [self &optional [k identity]] (self.value k))

  (defn bind [self f]
    "the bind operation of :class:`Continuation`"
    ((type self) (fn [k] (self.value (fn [v] (.value (f v) k))))))

  (with-decorator classmethod
    (defn unit [cls value]
      "the unit of continuation monad"
      (cls (fn [k] (k value)))))

  (defn run [self &optional [k identity]]
    "run the continuation"
    (self.value k)))

;;; alias
(def continuation-m Continuation)
(def cont-m Continuation)
(def unit Continuation.unit)
(def run Continuation.run)

(defn call-cc [f]
  "call with current continuation"
  (Continuation (fn [k] ((f (fn [v] (Continuation (constantly (k v))))) k))))
