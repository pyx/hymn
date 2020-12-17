;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.
"hymn.types.lazy - the lazy monad"

(import
  [hymn.types.monad [Monad]])

(defmacro lazy [&rest exprs]
  "create a :class:`Lazy` from expressions"
  (with-gensyms [lazy-m]
    `(do
       (import [hymn.types.lazy [lazy-m :as ~lazy-m]])
       (~lazy-m (fn [] ~@exprs)))))

(defclass Lazy [Monad]
  "the lazy monad

  lazy computation as monad"
  (defn __init__ [self value]
    (unless (callable value)
      (raise (TypeError (.format "{} object is not callable" value))))
    (setv self.value (, False value)))

  (defn __repr__ [self]
    (.format "{}({})"
             (name (type self))
             (if self.evaluated (repr (second self.value)) '_)))
  (defn bind [self f]
    "the bind operator of :class:`Lazy`"
    ((type self) (fn [] (.evaluate (f (.evaluate self))))))

  (with-decorator classmethod
    (defn unit [cls value] "the unit of lazy monad" (cls (constantly value))))

  (defn evaluate [self]
    "evaluate the lazy monad"
    (unless self.evaluated
     (setv self.value (, True ((second self.value)))))
    (second self.value))

  (with-decorator property
    (defn evaluated [self]
      "return :code:`True` if this computation is evaluated"
      (first self.value))))

;; alias
(setv lazy-m Lazy
      unit Lazy.unit
      evaluate Lazy.evaluate)

(defn force [m]
  "force the deferred computation :code:`m` if it is a :class:`Lazy`, act as
  function :code:`identity` otherwise, return the result"
  (if (instance? Lazy m) (.evaluate m) m))

(defn lazy? [v]
  "return :code:`True` if :code:`v` is a :class:`Lazy`"
  (instance? Lazy v))
