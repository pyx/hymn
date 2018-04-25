#!/usr/bin/env hy
;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2017, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.

;;; writer monad example

(import [hymn.dsl [tell]])

(require [hymn.macros [do-monad do-monad-m]])

(defn gcd [a b]
  (if (zero? b)
    (do-monad
      [_ (tell (.format "the result is: {}\n" (abs a)))]
      (abs a))
    (do-monad-m
      [_ (tell (.format "{} mod {} = {}\n" a b (% a b)))]
      (gcd b (% a b)))))

(defmain [&rest args]
  (if (-> args len (!= 3))
    (print "usage:" (first args) "number1 number2")
    (do
      (setv a (int (get args 1)) b (int (get args 2)))
      (print "calculating the greatest common divisor of" a "and" b)
      (print (.execute (gcd a b))))))
