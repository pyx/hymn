;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.
"hymn.mixins - mixin classes"

(import
  [functools [total-ordering]])

(with-decorator total-ordering
  (defclass Ord [object]
    "mixin class that implements rich comparison ordering methods"
    (defn __eq__ [self other]
      (if
        (is self other) True
        (instance? (type self) other) (= self.value other.value)
        NotImplemented))

    (defn __lt__ [self other]
      (if
        (is self other) False
        (instance? (type self) other) (< self.value other.value)
        (raise
          (TypeError
            (.format "unorderable types: {} and {}"
                     (type self) (type other))))))))
