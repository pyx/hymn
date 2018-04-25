;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2018, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hymn.mixins - mixin classes"

(import
  [functools [total-ordering]])

(with-decorator total-ordering
  (defclass Ord [object]
    "mixin class that implements rich comparison ordering methods"
    (defn --eq-- [self other]
      (if
        (is self other) True
        (instance? (type self) other) (= self.value other.value)
        NotImplemented))

    (defn --lt-- [self other]
      (if
        (is self other) False
        (instance? (type self) other) (< self.value other.value)
        (raise
          (TypeError
            (.format "unorderable types: {} and {}"
                     (type self) (type other))))))))
