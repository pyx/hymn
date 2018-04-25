;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2018, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.

(import [hymn.types.monoid [append <>]])

(defmacro m= [m1 m2]
  `(= (run ~m1) (run ~m2)))

(setv data 42)

(defn test-module-level-append [monoid-runner]
  "module should append should work"
  (setv [monoid run] monoid-runner)
  (setv e monoid.empty)
  (setv c (monoid.unit "Cuddles "))
  (setv t (monoid.unit "the "))
  (setv h (monoid.unit "Hacker!"))
  (assert (m= (append e e) e))
  (assert (m= (append c t h) (.append c (.append t h))))
  (assert (m= (append c e t e h) (.append (.append c t) h))))

(defn test-empty [monoid]
  "monoid should have an empty value"
  (assert (hasattr monoid 'empty))
  (assert (instance? monoid monoid.empty)))

(defn test-append [monoid-runner]
  "monoid should support append operation"
  (setv [monoid run] monoid-runner)
  (setv m (monoid.unit data))
  (assert (m= (.append monoid.empty monoid.empty) monoid.empty))
  (assert (m= (.append m monoid.empty) m))
  (assert (m= (.append monoid.empty m) m)))

(defn test-concat [monoid-runner]
  "monoid should support concat operation"
  (setv [monoid run] monoid-runner)
  (setv e monoid.empty)
  (setv x (monoid.unit "fizz"))
  (setv y (monoid.unit "buzz"))
  (setv z (monoid.unit "bazz"))
  (assert (m= (monoid.concat [x e y e z]) (monoid.concat [x y z]))))

(defn test-monoid-law-left-identity [monoid-runner]
  "monoid should satisfy monoid law: append empty m == m"
  (setv [monoid run] monoid-runner)
  (setv m (monoid.unit data))
  (assert (m= (append monoid.empty m) m)))

(defn test-monoid-law-right-identity [monoid-runner]
  "monoid should satisfy monoid law: append m empty == m"
  (setv [monoid run] monoid-runner)
  (setv m (monoid.unit data))
  (assert (m= (append m monoid.empty) m)))

(defn test-monoid-law-associativity [monoid-runner]
  "monoid should satisfy monoid law:
    append x (append y z) = append (append x y) z"
  (setv [monoid run] monoid-runner)
  (setv x (monoid.unit "fizz"))
  (setv y (monoid.unit "buzz"))
  (setv z (monoid.unit "bazz"))
  (assert (m= (append x (append y z)) (append (append x y) z))))
