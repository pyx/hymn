;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

(import
  itertools [islice]
  hymn.utils [CachedSequence
              thread-first thread-last
              constantly compose identity repeatedly])

(setv data 42)

(defn twice [n]
  (yield n)
  (yield n))

(defn test-cachedsequence []
  "CachedSequence should be reusable"
  (setv one-time (twice data))
  ;; consume all elements
  (assert (= 2 (len (list one-time))))
  ;; should be empty now
  (assert (= 0 (len (list one-time))))
  (setv s (CachedSequence (twice data)))
  (assert (= 2 (len s)))
  ;; should keep all elements
  (assert (= 2 (len s))))

(defn test-thread-first-function []
  "helper function thread-first"
  (assert '(b a) (thread-first 'a 'b))
  (assert '(b a c d) (thread-first 'a '(b c d))))

(defn test-thread-last-function []
  "helper function thread-last"
  (assert '(b a) (thread-first 'a 'b))
  (assert '(b c d a) (thread-first 'a '(b c d))))

(defn test-constantly-function []
  "constantly function: (c x)(y) = x"
  (assert (= data ((constantly data) (+ data 1)))))

(defn test-compose-function []
  "conpose function: (f . g) x = f (g x)"
  (defn f [x] (+ x 1))
  (defn g [x] (* x 2))
  (defn h [x] (** x 3))
  (defn identity [x] x)
  (for [x (range 10)]
    ;; left identity law
    (assert (= (f x) ((compose identity f) x)))
    ;; right identity law
    (assert (= (f x) ((compose f identity) x)))
    ;; associative law
    (assert (= (f (g (h x))) ((compose (compose f g) h) x)))))

(defn test-identity-function []
  "identity function: f(x) = x"
  (assert (= data (identity data))))

(defn test-repeatedly-function []
  "repeatedly function: applying the same function again and again"
  (setv c (repeatedly (fn [] data)))
  (assert (= [data data data data] (list (islice c 4)))))
