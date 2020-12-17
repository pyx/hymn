;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.
"hymn.types.reader - the reader monad"

(import
  [operator [itemgetter]]
  [hymn.types.monad [Monad]])

(defclass Reader [Monad]
  "the reader monad

  computations which read values from a shared environment"
  (defn __repr__ [self]
    (.format "{}({})" (name (type self)) (name self.value)))

  (defn bind [self f]
    "the bind operation of :class:`Reader`"
    ((type self) (fn [e] (.run (f (.run self e)) e))))

  (with-decorator classmethod
    (defn unit [cls value]
      "the unit of reader monad"
      (cls (constantly value))))

  (defn local [self f]
    "return a reader that execute computation in modified environment"
    ((type self) (fn [e] (.run self (f e)))))

  (defn run [self e]
    "run the reader and extract the final vaule"
    (self.value e)))

;; alias
(setv reader-m Reader
      run Reader.run
      unit Reader.unit)

(defn asks [f]
  "create a simple reader action from :code:`f`"
  (Reader f))
(setv reader asks)

(setv ask (reader identity))

(defn local [f]
  "executes a computation in a modified environment, :code:`f :: e -> e`"
  (fn [m] (m.local f)))

(defn lookup [key]
  "create a lookup reader of :code:`key` in the environment"
  (reader (itemgetter key)))
(setv <- lookup)
