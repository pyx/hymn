;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2017, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.

;;; NOTE:
;;; As stated on haskell wiki: http://www.haskell.org/haskellwiki/MonadPlus
;;; The precise set of rules that MonadPlus should obey is not agreed upon.
;;; More discussion here:
;;; http://www.haskell.org/haskellwiki/MonadPlus_reform_proposal
;;; This is my own interpretation, especially the implementation of Maybe
;;; Monad has unbiased plus, which satisfy Monoid and *Left Distribution*.

(require [hymn.macros [do-monad]])

(defmacro m= [m1 m2]
  `(= (run ~m1) (run ~m2)))

(def data 42)

(defn test-zero-implemented [monadplus]
  "monadplus should have zero"
  (assert (instance? monadplus monadplus.zero)))

(defn test-plus-implemented [monadplus]
  "monadplus should have plus method"
  (assert (instance? monadplus (monadplus.zero.plus monadplus.zero))))

(defn test-plus-operator [monadplus-runner]
  "monadplus should support + operator"
  (def [monadplus run] monadplus-runner)
  (def zero monadplus.zero)
  (assert (m= (+ zero zero) zero)))

(defn test-plus-zero-form-a-monoid [monadplus-runner]
  "with plus and zero, monadplus should be a monoid"
  (def [monadplus run] monadplus-runner)
  (def unit monadplus.unit)
  (def zero monadplus.zero)
  (def m (unit data))
  ;; zero is a neutral element
  ;; zero + m == m
  (assert (m= (+ zero m) m))
  (assert (m= (.plus zero m) m))
  ;; m + zero == m
  (assert (m= (+ m zero) m))
  (assert (m= (.plus m zero) m)))

(defn test-left-zero [monadplus-runner]
  "zero should be a left zero for bind"
  (def [monadplus run] monadplus-runner)
  (def unit monadplus.unit)
  (def zero monadplus.zero)
  (def m-inc (monadplus.monadic inc))
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
  (def [monadplus run] monadplus-runner)
  (def unit monadplus.unit)
  (def k (monadplus.monadic inc))
  (def m (unit data))
  (def n (unit (* data 2)))
  (assert (m= (>> (+ m n) k) (+ (>> m k) (>> n k)))))

(defn test-monadplus-do-monad-when [monadplus-runner]
  "do-monad macro should allow using :when to filter result"
  (def [monadplus run] monadplus-runner)
  (def unit monadplus.unit)
  (assert (m= (do-monad [a (unit data) :when (!= a data)] a)
              monadplus.zero)))
