;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.
"hymn.types.lazy - the lazy monad"

(import
  ..utils [constantly]
  .monad [Monad])

(defmacro lazy [#* exprs]
  "create a :class:`Lazy` from expressions"
  `(hy.M.hymn.types.lazy.lazy-m (fn [] ~@exprs)))

(defclass Lazy [Monad]
  "the lazy monad

  lazy computation as monad"
  (defn __init__ [self value]
    (when (not (callable value))
      (raise (TypeError (.format "{} object is not callable" value))))
    (setv self.value #(False value)))

  (defn __repr__ [self]
    (.format "{}({})"
             (. (type self) __name__)
             (if self.evaluated (repr (get self.value 1)) "_")))
  (defn bind [self f]
    "the bind operator of :class:`Lazy`"
    ((type self) (fn [] (.evaluate (f (.evaluate self))))))

  (defn [classmethod] unit [cls value]
    "the unit of lazy monad"
    (cls (constantly value)))

  (defn evaluate [self]
    "evaluate the lazy monad"
    (when (not self.evaluated)
     (setv self.value #(True ((get self.value 1)))))
    (get self.value 1))

  (defn [property] evaluated [self]
    "return :code:`True` if this computation is evaluated"
    (get self.value 0)))

(defn force [m]
  "force the deferred computation :code:`m` if it is a :class:`Lazy`, act as
  function :code:`identity` otherwise, return the result"
  (if (lazy? m) (.evaluate m) m))

(defn lazy? [v]
  "return :code:`True` if :code:`v` is a :class:`Lazy`"
  (isinstance v Lazy))

;; alias
(setv lazy-m Lazy
      is_lazy lazy?)

(export
  :objects [Lazy lazy-m force lazy? is_lazy]
  :macros [lazy])
