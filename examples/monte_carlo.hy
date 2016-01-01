#!/usr/bin/env hy
;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2016, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.

;;; state monad example

(import
  [collections [Counter]]
  [time [time]]
  [hymn.dsl [get-state replicate set-state]])

(require hymn.dsl)

;;; Knuth!
(def a 6364136223846793005)
(def c 1442695040888963407)
(def m (** 2 64))

;;; linear congruential generator
(def random
  (do-monad
    [seed get-state
     _ (set-state (-> seed (* a) (+ c) (% m)))
     new-seed get-state]
    (/ new-seed m)))

(def random-point (do-monad [x random y random] (, x y)))

(defn points [seed]
  "stream of random points"
  (while true
    ;; NOTE:
    ;; limited by the maximum recursion depth, we take 150 points each time
    (setv [random-points seed] (.run (replicate 150 random-point) seed))
    (for [point random-points]
      (yield point))))

(defn monte-carlo [number-of-points]
  "use monte carlo method to calculate value of pi"
  (def samples (take number-of-points (points (int (time)))))
  (def result
    (Counter (genexpr (>= 1.0 (+ (** x 2) (** y 2))) [[x y] samples])))
  (-> result (get true) (/ number-of-points) (* 4)))

(defmain [&rest args]
  (if (-> args len (!= 2))
    (print "usage:" (first args) "number-of-points")
    (print "the estimate for pi =" (-> args second int monte-carlo))))
