;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2023, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.
"hymn.types.reader - the reader monad"

(import
  operator [itemgetter]
  ..utils [constantly identity]
  .monad [Monad])

(defclass Reader [Monad]
  "the reader monad

  computations which read values from a shared environment"
  (defn __repr__ [self]
    (.format "{}({})" (. (type self) __name__) (. self.value) __name__))

  (defn bind [self f]
    "the bind operation of :class:`Reader`"
    ((type self) (fn [e] (.run (f (.run self e)) e))))

  (defn [classmethod] unit [cls value]
      "the unit of reader monad"
      (cls (constantly value)))

  (defn local [self f]
    "return a reader that execute computation in modified environment"
    ((type self) (fn [e] (.run self (f e)))))

  (defn run [self e]
    "run the reader and extract the final vaule"
    (self.value e)))

(defn asks [f]
  "create a simple reader action from :code:`f`"
  (Reader f))

(defn local [f]
  "executes a computation in a modified environment, :code:`f :: e -> e`"
  (fn [m] (m.local f)))

(defn lookup [key]
  "create a lookup reader of :code:`key` in the environment"
  (reader (itemgetter key)))

;; alias
(setv reader-m Reader
      reader asks
      ask (reader identity)
      <- lookup)

(export :objects [Reader reader-m reader asks ask local <- lookup])
