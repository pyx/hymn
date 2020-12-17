;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

;; NOTE:
;; As stated on haskell wiki: http://www.haskell.org/haskellwiki/MonadPlus
;; The precise set of rules that MonadPlus should obey is not agreed upon.
;; More discussion here:
;; http://www.haskell.org/haskellwiki/MonadPlus_reform_proposal
;; This is my own interpretation, especially the implementation of Maybe
;; Monad has unbiased plus, which satisfy Monoid and *Left Distribution*.

(require [hymn.macros [do-monad-return]])

(defmacro m= [m1 m2]
  `(= (run ~m1) (run ~m2)))

(setv data 42)

(defn test-zero-implemented [monadplus]
  "monadplus should have zero"
  (assert (instance? monadplus monadplus.zero)))

(defn test-plus-implemented [monadplus]
  "monadplus should have plus method"
  (assert (instance? monadplus (monadplus.zero.plus monadplus.zero))))

(defn test-plus-operator [monadplus-runner]
  "monadplus should support + operator"
  (setv [monadplus run] monadplus-runner
        zero monadplus.zero)
  (assert (m= (+ zero zero) zero)))

(defn test-plus-zero-form-a-monoid [monadplus-runner]
  "with plus and zero, monadplus should be a monoid"
  (setv [monadplus run] monadplus-runner
        unit monadplus.unit
        zero monadplus.zero
        m (unit data))
  ;; zero is a neutral element
  ;; zero + m == m
  (assert (m= (+ zero m) m))
  (assert (m= (.plus zero m) m))
  ;; m + zero == m
  (assert (m= (+ m zero) m))
  (assert (m= (.plus m zero) m)))

(defn test-left-zero [monadplus-runner]
  "zero should be a left zero for bind"
  (setv [monadplus run] monadplus-runner
        unit monadplus.unit
        zero monadplus.zero
        m-inc (monadplus.monadic inc))
  ;; v >> zero = zero
  ;; Not testing this since the >> we implemented is actually >>= in haskell,
  ;; if we really want to do it, here is how:
  ; (defn bind-and-discard [m other] (>> m (fn [_] other)))
  ; (assert (m= (bind-and-discard (unit data) zero) zero)))
  ; zero >>= f = zero
  (assert (m= (>> zero m-inc) zero)))

(defn test-left-distribution [monadplus-runner]
  "monadplus should satisfy left distribution"
  ;; plus a b >>= k = plus (a >>= k) (b >>= k)
  (setv [monadplus run] monadplus-runner
        unit monadplus.unit
        k (monadplus.monadic inc)
        m (unit data)
        n (unit (* data 2)))
  (assert (m= (>> (+ m n) k) (+ (>> m k) (>> n k)))))

(defn test-monadplus-do-monad-when [monadplus-runner]
  "do-monad-return macro should allow using :when to filter result"
  (setv [monadplus run] monadplus-runner
        unit monadplus.unit)
  (assert (m= (do-monad-return [a (unit data) :when (!= a data)] a)
              monadplus.zero)))
