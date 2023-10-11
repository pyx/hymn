#!/usr/bin/env hy
;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

;; writer monad example

(import hymn.dsl [tell])

(require hymn.dsl [do-monad do-monad-return])

(defn gcd [a b]
  (if (= 0 b)
    (do-monad-return
      [_ (tell (.format "the result is: {}\n" (abs a)))]
      (abs a))
    (do-monad
      [_ (tell (.format "{} mod {} = {}\n" a b (% a b)))]
      (gcd b (% a b)))))

(when (= __name__ "__main__")
  (import sys)
  (setv [prog_name #* args] sys.argv)
  (if (!= 2 (len args))
    (print "usage:" prog_name "number1 number2")
    (do
      (setv [a b] args)
      (print "calculating the greatest common divisor of" a "and" b)
      (print (.execute (gcd (int a) (int b)))))))
