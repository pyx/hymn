;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2023, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.
"hymn.types.continuation - the continuation monad"

(import
  ..utils [constantly identity]
  .monad [Monad])

(defreader < (setv v (.parse-one-form &reader))
  `(hy.I.hymn.types.continuation.Continuation.unit ~v))

(defclass Continuation [Monad]
  "the continuation monad"
  (defn __repr__ [self]
    (.format "{}({})" (. (type self) __name__) self.value.__name__))

  (defn __call__ [self [k identity]] (self.value k))

  (defn bind [self f]
    "the bind operation of :class:`Continuation`"
    ((type self) (fn [k] (self.value (fn [v] (.value (f v) k))))))

  (defn [classmethod] unit [cls value]
    "the unit of continuation monad"
    (cls (fn [k] (k value))))

  (defn run [self [k identity]]
    "run the continuation"
    (self.value k)))

(defn call-cc [f]
  "call with current continuation"
  (Continuation (fn [k] ((f (fn [v] (Continuation (constantly (k v))))) k))))

;; alias
(setv continuation-m Continuation
      cont-m Continuation
      call/cc call-cc)

(export :objects [continuation-m cont-m Continuation call-cc])
