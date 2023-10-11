#!/usr/bin/env hy
;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2023, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

;; maybe monad example
;; The fizzbuzz test, in the style inspired by c_wraith on Freenode #haskell

(import
  itertools [chain cycle]
  hymn.dsl [<> from-maybe maybe-m])

(require hymn.dsl [do-monad-with])

(defn fizzbuzz [i]
  (from-maybe
    (<>
      (do-monad-with maybe-m [:when (= 0 (% i 3))] "fizz")
      (do-monad-with maybe-m [:when (= 0 (% i 5))] "buzz"))
    (str i)))

;; using monoid operation, it is easy to add new case, just add one more line
;; in the append (<>) call. e.g
(defn fizzbuzzbazz [i]
  (from-maybe
    (<>
      (do-monad-with maybe-m [:when (= 0 (% i 3))] "fizz")
      (do-monad-with maybe-m [:when (= 0 (% i 5))] "buzz")
      (do-monad-with maybe-m [:when (= 0 (% i 7))] "bazz"))
    (str i)))

(defn interleave [#* ss]
  (chain.from-iterable (zip #* ss)))

(defn format [seq]
  (.join "" (interleave seq (cycle "\t\t\t\t\n"))))

(when (= __name__ "__main__")
  (import sys)
  (setv [prog_name #* args] sys.argv)
  (if (!= 1 (len args))
    (print "usage:" prog_name "up-to-number")
    (print (format (map fizzbuzz (range 1 (+ (int (get args 0)) 1)))))))
