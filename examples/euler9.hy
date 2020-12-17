#!/usr/bin/env hy
;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

;; list monad example

(require
  [hymn.macros [do-monad-return]]
  [hymn.types.list [~]])

(setv total 1000
      limit (-> total (** 0.5) int inc))

(setv triplet
  (do-monad-return
    [m #~ (range 2 limit)
     n #~ (range 1 m)
     :let [a (- (** m 2) (** n 2))
           b (* 2 m n)
           c (+ (** m 2) (** n 2))]
     :when (-> (+ a b c) (= total))]
    [a b c]))

(defmain [&rest args]
  (print "Project Euler Problem 9 - list monad example"
         "https://projecteuler.net/problem=9"
         "There exists exactly one Pythagorean triplet"
         "for which a + b + c = 1000.  Find the product abc."
         (->> triplet first (reduce *))
         :sep "\n"))
