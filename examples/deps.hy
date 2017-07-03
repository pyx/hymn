#!/usr/bin/env hy
;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2017, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.

;;; lazy monad example

(import [hymn.dsl [force lift]])

(require [hymn.macros [lazy]])

(def depends (lift (constantly None)))

(defmacro deftask [n &rest actions]
  `(def ~n
     (depends (lazy (print "(started" '~n))
              ~@actions
              (lazy (print " finished " '~n ")" :sep "")))))

(deftask a)
(deftask b)
(deftask c)
(deftask d)
(deftask e)
(deftask f (depends c a))
(deftask g (depends b d))
(deftask h (depends g e f))

(defmain [&rest args]
  (force h))
