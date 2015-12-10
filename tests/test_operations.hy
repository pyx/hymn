;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2015, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.

(import
  [hymn.types.identity [identity-m]]
  [hymn.operations [k-compose <=< k-pipe >=> lift replicate sequence]])

(defmacro m= [m1 m2]
  `(= (run ~m1) (run ~m2)))

(def data 42)

(defn test-l-to-r-kleisli-composition [monad-runner]
  "left to right Kleisli composition of monads should work"
  (def [monad run] monad-runner)
  (def m-inc (monad.monadic inc))
  (def m-double (monad.monadic (fn [n] (* n 2))))
  (def m (monad.unit data))
  (assert (m= (>> m (k-pipe m-inc m-double)) (>> m m-inc m-double)))
  (assert (m= (>> m (>=> m-inc m-double)) (>> m m-inc m-double))))

(defn test-r-to-l-kleisli-composition [monad-runner]
  "right to left Kleisli composition of monads should work"
  (def [monad run] monad-runner)
  (def m-inc (monad.monadic inc))
  (def m-double (monad.monadic (fn [n] (* n 2))))
  (def m (monad.unit data))
  (assert (m= (>> m (k-compose m-inc m-double)) (<< m-inc (<< m-double m))))
  (assert (m= (>> m (<=< m-inc m-double)) (<< m-inc (<< m-double m)))))

(defn test-lift [monad-runner]
  "lift should promote a function to a monad"
  (def [monad run] monad-runner)
  (def minc (lift inc))
  (def unit monad.unit)
  (assert (instance? monad (minc (unit data))))
  (assert (m= (minc (unit data)) (unit (inc data)))))

(defn test-lift-no-argument []
  "lift should work on functions called with no argument"
  (def mint (lift int))
  (def mlist (lift list))
  (assert (instance? identity-m (mint)))
  (assert (instance? identity-m (mlist)))
  (assert (= (>> (mint) identity) (int)))
  (assert (= (>> (mlist) identity) (list))))

(defn test-lift-multiple-arguments [monad-runner]
  "lift should work on functions having multiple arguments"
  (def [monad run] monad-runner)
  (def unit monad.unit)
  (def m+ (lift +))
  (def a1 data)
  (def m1 (unit a1))
  (def a2 (inc a1))
  (def m2 (unit a2))
  (def a3 (inc a2))
  (def m3 (unit a3))
  (assert (m= (m+ m1 m2 m3) (unit (+ a1 a2 a3)))))

(defn test-lift-keyword-arguments [monad-runner]
  "lift should work on functions having keyword arguments"
  (def [monad run] monad-runner)
  (def unit monad.unit)
  (def mint (lift int))
  (assert (m= (mint (unit (str data)) :base (unit 16))
              (unit (int (str data) :base 16)))))

(defn test-lift-only-keyword-arguments [monad-runner]
  "lift should work on functions passing only keyword arguments"
  (def [monad run] monad-runner)
  (def unit monad.unit)
  (def mcomplex (lift complex))
  (assert (m= (mcomplex :imag (unit data))
              (unit (complex :imag data)))))

(defn test-replicate [monad-runner]
  "replicate should perform the monadic action said times"
  (def [monad run] monad-runner)
  (def unit monad.unit)
  (def m (unit data))
  (def n 5)
  (def result (* [data] n))
  (assert (instance? monad (replicate n m)))
  (assert (m= (replicate n m) (unit result))))

(defn test-sequence [monad-runner]
  "sequence should work on all monads"
  (def [monad run] monad-runner)
  (def unit monad.unit)
  (def values (list (range data (+ data 5))))
  (assert (instance? monad (sequence (map unit values))))
  (assert (m= (sequence (map unit values)) (unit values))))

(defn test-sequence-empty []
  "sequence should return empty list in identity monad when values list empty"
  (assert (instance? identity-m (sequence [])))
  (assert (= (>> (sequence []) identity) [])))
