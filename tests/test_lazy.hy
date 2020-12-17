;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

(import
  [hymn.types [lazy :as lazy-module]]
  [hymn.types.lazy [lazy-m force lazy?]])

(require [hymn.types.lazy [lazy]])

(defn test-macro-lazy []
  "macro lazy should create deferred computation"
  (assert (instance? lazy-m (lazy 1))))

(defn test-module-level-unit []
  "lazy module should have a working module level unit function"
  (assert (instance? lazy-m (lazy-module.unit 1))))

(defn test-module-level-evaluate []
  "lazy module should have a module level evaluate function"
  (assert (= (.evaluate (lazy 2)) (lazy-module.evaluate (lazy 2)))))

(defn test-lazy-should-be-lazy []
  "make sure the computation is deferred"
  (setv a [1 2])
  (assert (= (len a) 2))
  (setv m (lazy (.pop a) 3))
  (assert (= (len a) 2)))

(defn test-lazy-evaluate-only-once []
  "lazy should be evaluate only once"
  (setv a [1 2])
  (assert (= (len a) 2))
  (setv m (lazy (.pop a) 42))
  (assert (= (len a) 2))
  (assert (= (.evaluate m) 42))
  (assert (= (len a) 1))
  (assert (= (.evaluate m) 42))
  (assert (= (len a) 1)))

(defn test-force []
  "force should works as .evaluate"
  (setv a [1 2])
  (assert (= (len a) 2))
  (setv m (lazy (.pop a) 42))
  (assert (= (len a) 2))
  (assert (= (force m) 42))
  (assert (= (len a) 1))
  (assert (= (force m) 42))
  (assert (= (len a) 1)))

(defn test-force-work-on-other-values []
  "force can be used with values other than lazy"
  (assert (= (force 42) 42)))

(defn test-is-lazy []
  "lazy? should work"
  (assert (lazy? (lazy-m.unit 1)))
  (assert (not (lazy? 1))))
