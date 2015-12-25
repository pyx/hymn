;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2015, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.

(import
  [hymn.utils [CachedSequence compose const pipe]])

(def data 42)

(defn twice [n]
  (yield n)
  (yield n))

(defn test-cachedsequence []
  "CachedSequence should be reusable"
  (def one-time (twice data))
  ;; consume all elements
  (assert (= 2 (len (list one-time))))
  ;; should be empty now
  (assert (= 0 (len (list one-time))))
  (def s (CachedSequence (twice data)))
  (assert (= 2 (len s)))
  ;; should keep all elements
  (assert (= 2 (len s))))

(defn test-compose-left-identity []
  "function composition should satisfy left identity"
  (def f inc)
  (def g (compose identity f))
  (assert (= (f data) (g data))))

(defn test-compose-right-identity []
  "function composition should satisfy right identity"
  (def f inc)
  (def g (compose f identity))
  (assert (= (f data) (g data))))

(defn test-compose-associative []
  "function composition should be associative"
  ;; NOTE:
  ;; these functions are specifically chosen, so that when composed in
  ;; different orders, yield different results.
  (def f hash)
  (def g str)
  (def h type)
  (def f1 (compose f (compose g h)))
  (def f2 (compose (compose f g) h))
  (def values [data 0.5 '42 sum f (fn [_] 0)])
  (for [value values]
    (assert (= (f1 value) (f2 value))))
    (assert (!= (f1 value) ((compose f (compose h g)) value)))
    (assert (!= (f2 value) ((compose f (compose h g)) value)))
    (assert (!= (f1 value) ((compose g (compose f h)) value)))
    (assert (!= (f2 value) ((compose g (compose f h)) value)))
    (assert (!= (f1 value) ((compose g (compose h f)) value)))
    (assert (!= (f2 value) ((compose g (compose h f)) value)))
    (assert (!= (f1 value) ((compose h (compose g f)) value)))
    (assert (!= (f2 value) ((compose h (compose g f)) value)))
    (assert (!= (f1 value) ((compose h (compose f g)) value)))
    (assert (!= (f2 value) ((compose h (compose f g)) value))))

(defn test-compose-multiple-functions []
  "compose should be able to compose multiple functions"
  (def fs (* [inc] data))
  (assert (= ((apply compose fs) 0) data)))

(defn test-const []
  "const should alway return the constant value passed in when constructed"
  (def singleton (object))
  (def that (const singleton))
  (assert (is (that data) (that 123)))
  (assert (is (that 1 2 3 4 5 6) (that)))
  (assert (is (that 1 2 3 :a 4 :b 5 :c 6) (that that))))

(defn test-pipe-equal-reverse-compose []
  "pipe should work as reversed composition"
  (def f hash)
  (def g str)
  (def h type)
  (assert (= ((compose f g h) data) ((pipe h g f) data)))
  (assert (!= ((compose f g h) data) ((pipe f g h) data))))

(defn test-pipe-multiple-functions []
  "pipe should be able to pipe multiple functions"
  (def fs (* [inc] data))
  (assert (= ((apply pipe fs) 0) data)))
