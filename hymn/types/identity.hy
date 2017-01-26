;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2017, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hymn.types.identity - the identity monad"

(import
  [hymn.mixins [Ord]]
  [hymn.types.monad [Monad]])

(defclass Identity [Monad Ord]
  "the identity monad"
  (defn bind [self f] (f self.value)))

;;; alias
(def identity-m Identity)
(def unit Identity.unit)
