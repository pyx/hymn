#!/usr/bin/env hy
;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

;; list monad example

(import functools [reduce]
        hy.pyops [*])

(require hymn.dsl [do-monad-return] :readers [@])

(setv total 1000
      limit (+ (int (** total 0.5)) 1))

(setv triplet
  (do-monad-return
    [m #@ (range 2 limit)
     n #@ (range 1 m)
     :let [a (- (** m 2) (** n 2))
           b (* 2 m n)
           c (+ (** m 2) (** n 2))]
     :when (= total (+ a b c))]
    [a b c]))

(when (= __name__ "__main__")
  (print "Project Euler Problem 9 - list monad example"
         "https://projecteuler.net/problem=9"
         "There exists exactly one Pythagorean triplet"
         "for which a + b + c = 1000.  Find the product abc."
         (reduce * (next (iter triplet)))
         :sep "\n"))
