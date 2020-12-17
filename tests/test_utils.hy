;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

(import
  [hymn.utils [CachedSequence]])

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
