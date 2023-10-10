;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.
"hymn.mixins - mixin classes"

(import functools [total-ordering])

(defclass [total-ordering] Ord [object]
  "mixin class that implements rich comparison ordering methods"
  (defn __eq__ [self other]
    (cond
      (is self other) True
      (isinstance other (type self)) (= self.value other.value)
      True NotImplemented))

  (defn __lt__ [self other]
    (cond
      (is self other) False
      (isinstance other (type self)) (< self.value other.value)
      True (raise
        (TypeError
          (.format "unorderable types: {} and {}"
                   (type self) (type other)))))))

(export :objects [Ord])
