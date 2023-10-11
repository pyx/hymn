#!/usr/bin/env hy
;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2023, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

;; writer monad example

(import hymn.dsl [sequence tell])

(defn wicked-sum [numbers]
  (.execute (sequence (map tell numbers))))

(when (= __name__ "__main__")
  (import sys)
  (setv [prog_name #* args] sys.argv)
  (if (= 0 (len args))
    (print "usage:" prog_name "number1 number2 .. numberN")
    (print "sum:" (wicked-sum (map int args)))))
