#!/usr/bin/env hy
;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

;; continuation monad example

(import [hymn.dsl [cont-m call-cc]])

(require [hymn.macros [do-monad-return m-when with-monad]])

(defn validate [name exit]
  (with-monad cont-m
    (m-when (not name) (exit "Please tell me your name!"))))

(defn greeting [name]
  (.run (call-cc
          (fn [exit]
            (do-monad-return
              [_ (validate name exit)]
              (+ "Welcome, " name "!"))))))

(defmain [&rest args]
  (print (greeting (input "Hi, what is your name? "))))
