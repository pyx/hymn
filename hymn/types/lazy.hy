;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2015, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hymn.types.lazy - the lazy monad"

(import
  [hymn.types.monad [Monad]]
  [hymn.utils [const]])

(defmacro lazy [&rest exprs]
  "create a :class:`Lazy` from expressions"
  (with-gensyms [lazy-m]
    `(do
       (import [hymn.types.lazy [lazy-m :as ~lazy-m]])
       (~lazy-m (fn [] ~@exprs)))))

(defclass Lazy [Monad]
  "the lazy monad

  lazy computation as monad"
  [[--init-- (fn [self value]
               (unless (callable value)
                 (raise
                   (TypeError (.format "{} object is not callable" value))))
               (def self.value (, false value))
               nil)]
   [--repr-- (fn [self]
               (.format "{}({})"
                        (. (type self) --name--)
                        (if self.evaluated (repr (second self.value)) '_)))]
   [bind (fn [self f]
           "the bind operator of :class:`Lazy`"
           ((type self) (fn [] (.evaluate (f (.evaluate self))))))]
   [unit (with-decorator classmethod
           (fn [cls value] "the unit of lazy monad" (cls (const value))))]
   [evaluate (fn [self]
               "evaluate the lazy monad"
               (unless self.evaluated
                 (setv self.value (, true ((second self.value)))))
               (second self.value))]
   [evaluated (with-decorator property
                (fn [self]
                  "return :code:`True` if this computation is evaluated"
                  (first self.value)))]])

;;; alias
(def lazy-m Lazy)
(def unit Lazy.unit)
(def evaluate Lazy.evaluate)

(defn force [m]
  "force the deferred computation :code:`m` if it is a :class:`Lazy`, act as
  function :code:`identity` otherwise, return the result"
  (if (instance? Lazy m) (.evaluate m) m))

(defn lazy? [v]
  "return :code:`True` if :code:`v` is a :class:`Lazy`"
  (instance? Lazy v))
