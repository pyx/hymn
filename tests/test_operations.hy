;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

(import
  [hymn.types.identity [identity-m]]
  [hymn.operations [k-compose <=< k-pipe >=> lift m-map replicate sequence]])

(defmacro m= [m1 m2]
  `(= (run ~m1) (run ~m2)))

(setv data 42)

(defn test-l-to-r-kleisli-composition [monad-runner]
  "left to right Kleisli composition of monads should work"
  (setv [monad run] monad-runner
        m-inc (monad.monadic inc)
        m-double (monad.monadic (fn [n] (* n 2)))
        m (monad.unit data))
  (assert (m= (>> m (k-pipe m-inc m-double)) (>> m m-inc m-double)))
  (assert (m= (>> m (>=> m-inc m-double)) (>> m m-inc m-double))))

(defn test-r-to-l-kleisli-composition [monad-runner]
  "right to left Kleisli composition of monads should work"
  (setv [monad run] monad-runner
        m-inc (monad.monadic inc)
        m-double (monad.monadic (fn [n] (* n 2)))
        m (monad.unit data))
  (assert (m= (>> m (k-compose m-inc m-double)) (<< m-inc (<< m-double m))))
  (assert (m= (>> m (<=< m-inc m-double)) (<< m-inc (<< m-double m)))))

(defn test-lift [monad-runner]
  "lift should promote a function to a monad"
  (setv [monad run] monad-runner
        minc (lift inc)
        unit monad.unit)
  (assert (instance? monad (minc (unit data))))
  (assert (m= (minc (unit data)) (unit (inc data)))))

(defn test-lift-no-argument []
  "lift should work on functions called with no argument"
  (setv mint (lift int)
        mlist (lift list))
  (assert (instance? identity-m (mint)))
  (assert (instance? identity-m (mlist)))
  (assert (= (>> (mint) identity) (int)))
  (assert (= (>> (mlist) identity) (list))))

(defn test-lift-multiple-arguments [monad-runner]
  "lift should work on functions having multiple arguments"
  (setv [monad run] monad-runner
        unit monad.unit
        m+ (lift +)
        a1 data
        m1 (unit a1)
        a2 (inc a1)
        m2 (unit a2)
        a3 (inc a2)
        m3 (unit a3))
  (assert (m= (m+ m1 m2 m3) (unit (+ a1 a2 a3)))))

(defn test-lift-keyword-arguments [monad-runner]
  "lift should work on functions having keyword arguments"
  (setv [monad run] monad-runner
        unit monad.unit
        mint (lift int))
  (assert (m= (mint (unit (str data)) :base (unit 16))
              (unit (int (str data) :base 16)))))

(defn test-lift-only-keyword-arguments [monad-runner]
  "lift should work on functions passing only keyword arguments"
  (setv [monad run] monad-runner
        unit monad.unit
        mcomplex (lift complex))
  (assert (m= (mcomplex :imag (unit data))
              (unit (complex :imag data)))))

(defn test-m-map [monad-runner]
  "m-map should work as :code:`sequence . map f`"
  (setv [monad run] monad-runner
        minc (monad.monadic inc))
  (assert (= (list (run (sequence (map minc (range 42)))))
             (list (run (m-map minc (range 42)))))))

(defn test-replicate [monad-runner]
  "replicate should perform the monadic action said times"
  (setv [monad run] monad-runner
        unit monad.unit
        m (unit data)
        n 5
        result (* [data] n))
  (assert (instance? monad (replicate n m)))
  (assert (m= (replicate n m) (unit result))))

(defn test-sequence [monad-runner]
  "sequence should work on all monads"
  (setv [monad run] monad-runner
        unit monad.unit
        values (list (range data (+ data 5))))
  (assert (instance? monad (sequence (map unit values))))
  (assert (m= (sequence (map unit values)) (unit values))))

(defn test-sequence-empty []
  "sequence should return empty list in identity monad when values list empty"
  (assert (instance? identity-m (sequence [])))
  (assert (= (>> (sequence []) identity) [])))
