#!/usr/bin/env hy
;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2015, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.

;;; writer monad example

(import [hymn.dsl [sequence tell]])
(require hymn.dsl)

(defn wicked-sum [numbers]
  (.execute (sequence (map tell numbers))))

(defmain [&rest args]
  (if (-> args len (= 1))
    (print "usage:" (get args 0) "number1 number2 .. numberN")
    (print "sum:" (wicked-sum (map int (slice args 1))))))
