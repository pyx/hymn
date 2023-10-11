#!/usr/bin/env hy
;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2023, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

;; state monad example

(import
  collections [Counter]
  itertools [islice]
  time [time]
  hymn.dsl [get-state replicate set-state])

(require hymn.dsl [do-monad-return])

;; Knuth!
(setv a 6364136223846793005
      c 1442695040888963407
      m (** 2 64))

;; linear congruential generator
(setv random
  (do-monad-return
    [seed get-state
     _ (set-state (% (+ (* seed a) c) m))
     new-seed get-state]
    (/ new-seed m)))

(setv random-point (do-monad-return [x random y random] #(x y)))

(defn points [seed]
  "stream of random points"
  (while True
    ;; NOTE:
    ;; limited by the maximum recursion depth, we take 150 points each time
    (setv [random-points seed] (.run (replicate 150 random-point) seed))
    (for [point random-points]
      (yield point))))

(defn monte-carlo [number-of-points]
  "use monte carlo method to calculate value of pi"
  (setv
    samples (islice (points (int (time))) number-of-points)
    result (Counter (gfor [x y] samples (>= 1.0 (+ (** x 2) (** y 2))))))
  (* 4 (/ (get result True) number-of-points)))

(when (= __name__ "__main__")
  (import sys)
  (setv args sys.argv)
  (if (!= 2 (len args))
    (print "usage:" (get args 0) "number-of-points")
    (print "the estimate for pi =" (monte-carlo (int (get args 1))))))
