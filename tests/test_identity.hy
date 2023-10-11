;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2023, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

(import hymn.types.identity [identity-m])

(defn test-ord-mixin []
  "identity should be comparable, with mixin Ord"
  (assert (< (identity-m.unit 98) (identity-m.unit 731)))
  (assert (!= (identity-m.unit None) (identity-m.unit "")))
  (assert (= (identity-m.unit False) (identity-m.unit False))))
