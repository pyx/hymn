;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

(defmacro m= [m1 m2]
  `(= (run ~m1) (run ~m2)))

(setv data 42
      double (fn [n] (* n 2)))

(defn test-unit [monad]
  "unit should act as a constructor"
  (assert (instance? monad (monad.unit data))))

(defn test-monadic [monad]
  "monadic should turn a fucntion into a monadic one"
  (setv m-inc (monad.monadic inc))
  (assert (instance? monad (m-inc data))))

(defn test-join [monad-runner]
  "join should remove one level of monadic structure"
  (setv [monad run] monad-runner
        unit monad.unit)
  (assert (m= (.join (unit (unit data))) (unit data))))

(defn test-bind [monad-runner]
  "bind should combine monadic computation"
  (setv [monad run] monad-runner
        unit monad.unit
        m-inc (monad.monadic inc))
  (assert (m= (.bind (unit data) m-inc) (unit (inc data)))))

(defn test-bind-operator [monad-runner]
  "bind operator should work"
  (setv [monad run] monad-runner
        unit monad.unit
        m-inc (monad.monadic inc))
  ;; bind operator should work
  (assert (m= (>> (unit data) m-inc) (unit (inc data))))
  ;; bind operator should work in the same way as .bind
  (assert (m= (>> (unit data) m-inc) (.bind (unit data) m-inc))))

(defn test-reverse-bind-operator [monad-runner]
  "reverse bind operator should work"
  (setv [monad run] monad-runner
        unit monad.unit
        m-inc (monad.monadic inc))
  ;; reverse bind operator should work
  (assert (m= (<< m-inc (unit data)) (unit (inc data))))
  ;; reverse bind operator should work as the bind operator reversed
  (assert (m= (<< m-inc (unit data)) (>> (unit data) m-inc))))

(defn test-chain-bind-operator [monad-runner]
  "bind operator should be able to be chained together"
  (setv [monad run] monad-runner
        unit monad.unit
        m-inc (monad.monadic inc)
        m-double (monad.monadic double))
  (assert (m= (>> (unit data) m-inc m-double) (unit (double (inc data))))))

(defn test-monad-law-left-identity [monad-runner]
  "monad should satisfy monad law: unit n >>= f == f n"
  (setv [monad run] monad-runner
        unit monad.unit
        m-inc (monad.monadic inc))
  (assert (m= (>> (unit data) m-inc) (m-inc data))))

(defn test-monad-law-right-identity [monad-runner]
  "monad should satisfy monad law: m >> unit == m"
  (setv [monad run] monad-runner
        unit monad.unit)
  (assert (m= (>> (unit data) unit) (unit data))))

(defn test-monad-law-associativity [monad-runner]
  "monad should satisfy monad law: m >>= (λx -> k x >>= h) == (m >>= k) >>= h"
  (setv [monad run] monad-runner
        unit monad.unit
        m (unit data)
        k (monad.monadic inc)
        h (monad.monadic double))
  (assert (m= (>> m (fn [x] (>> (k x) h))) (>> m k h))))
