#!/usr/bin/env hy
;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

;; list and maybe monad example

(import
  [functools [partial]]
  [itertools [permutations]])

(require
  [hymn.macros [do-monad do-monad-return]]
  [hymn.types.list [~]]
  [hymn.types.maybe [?]])

(setv ops [+ - * /])

(defmacro infix-repr [fmt]
  `(.format ~fmt :a a :b b :c c :d d :op1 (name op1)
            :op2 (name op2) :op3 (name op3)))

;; use maybe monad to handle division by zero
(defmacro safe [expr] `(#? (fn [] ~expr)))

(defn template [numbers]
  (setv [a b c d] numbers)
  (do-monad
    [op1 #~ ops
     op2 #~ ops
     op3 #~ ops]
    ;; (, result infix-representation)
    [(, (safe (op1 (op2 a b) (op3 c d)))
        (infix-repr "({a} {op2} {b}) {op1} ({c} {op3} {d})"))
     (, (safe (op1 a (op2 b (op3 c d))))
        (infix-repr "{a} {op1} ({b} {op2} ({c} {op3} {d}))"))
     (, (safe (op1 (op2 (op3 a b) c) d))
        (infix-repr "(({a} {op3} {b}) {op2} {c}) {op1} {d}"))]))

(defn combinations [numbers]
  (do-monad-return
    [:let [seemed (set)]
     [a b c d] #~ (permutations numbers 4)
     :when (not-in (, a b c d) seemed)]
    (do
      (.add seemed (, a b c d))
      [a b c d])))

;; In python, 8 / (3 - (8 / 3)) = 23.99999999999999, it should be 24 in fact,
;; so we have to use custom comparison function like this
(defn close-enough [a b] (< (abs (- a b)) 0.0001))

(defn solve [numbers]
  (do-monad-return
    [[result infix-repr] (<< template (combinations numbers))
     :when (>> result (partial close-enough 24))]
    infix-repr))

(defmain [&rest args]
  (if (-> args len (!= 5))
    (print "usage:" (first args) "number1 number2 number3 number4")
    (->> args rest (map int) solve (.join "\n") print)))
