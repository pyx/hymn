#!/usr/bin/env hy
;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

;; writer monad example

(import [hymn.dsl [sequence tell]])

(defn wicked-sum [numbers]
  (.execute (sequence (map tell numbers))))

(defmain [&rest args]
  (if (-> args len (= 1))
    (print "usage:" (first args) "number1 number2 .. numberN")
    (print "sum:" (->> args rest (map int) wicked-sum))))
