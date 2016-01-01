;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2016, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hymn.mixins - mixin classes"

(import
  [functools [total-ordering]])

(with-decorator total-ordering
  (defclass Ord [object]
    "mixin class that implements rich comparison ordering methods"
    [[--eq-- (fn [self other]
               (cond
                 [(is self other) true]
                 [(instance? (type self) other) (= self.value other.value)]
                 [true NotImplemented]))]
     [--lt-- (fn [self other]
               (cond
                 [(is self other) false]
                 [(instance? (type self) other) (< self.value other.value)]
                 [true (->
                         "unorderable types: {} and {}"
                         (.format (type self) (type other))
                         TypeError
                         raise)]))]]))
