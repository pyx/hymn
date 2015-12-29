;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2015, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hymn.types.reader - the reader monad"

(import
  [operator [itemgetter]]
  [hymn.types.monad [Monad]]
  [hymn.utils [const]])

(defclass Reader [Monad]
  "the reader monad

  computations which read values from a shared environment"
  [[--repr-- (fn [self]
               (.format "{}({})"
                        (. (type self) --name--) self.value.--name--))]
   [bind (fn [self f]
           "the bind operation of :class:`Reader`"
           ((type self) (fn [e] (.run (f (.run self e)) e))))]
   [unit (with-decorator classmethod
           (fn [cls value] "the unit of reader monad" (cls (const value))))]
   [local (fn [self f]
            "return a reader that execute computation in modified environment"
            ((type self) (fn [e] (.run self (f e)))))]
   [run (fn [self e]
          "run the reader and extract the final vaule"
          (self.value e))]])

;;; alias
(def reader-m Reader)
(def run Reader.run)
(def unit Reader.unit)

(defn-alias [asks reader] [f]
  "create a simple reader action from :code:`f`"
  (Reader f))

(def ask (reader identity))

(defn local [f]
  "executes a computation in a modified environment, :code:`f :: e -> e`"
  (fn [m] (m.local f)))

(defn-alias [lookup <-] [key]
  "create a lookup reader of :code:`key` in the environment"
  (reader (itemgetter key)))
