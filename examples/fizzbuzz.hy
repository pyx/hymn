#!/usr/bin/env hy
;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

;; maybe monad example
;; The fizzbuzz test, in the style inspired by c_wraith on Freenode #haskell

(import [hymn.dsl [<> from-maybe maybe-m]])

(require [hymn.macros [do-monad-with]])

(defn fizzbuzz [i]
  (from-maybe
    (<>
      (do-monad-with maybe-m [:when (zero? (% i 3))] "fizz")
      (do-monad-with maybe-m [:when (zero? (% i 5))] "buzz"))
    (str i)))

;; using monoid operation, it is easy to add new case, just add one more line
;; in the append (<>) call. e.g
(defn fizzbuzzbazz [i]
  (from-maybe
    (<>
      (do-monad-with maybe-m [:when (zero? (% i 3))] "fizz")
      (do-monad-with maybe-m [:when (zero? (% i 5))] "buzz")
      (do-monad-with maybe-m [:when (zero? (% i 7))] "bazz"))
    (str i)))

(defn format [seq]
  (.join "" (interleave seq (cycle "\t\t\t\t\n"))))

(defmain [&rest args]
  (if (-> args len (= 1))
    (print "usage:" (first args) "up-to-number")
    (print (->> args second int inc (range 1) (map fizzbuzz) format))))
