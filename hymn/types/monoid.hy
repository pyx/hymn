;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.
"hymn.types.monoid - base monoid class"

(import functools [reduce])

(defclass Monoid []
  "the monoid class

  types with an associative binary operation that has an identity"
  (defn [property] empty [self]
    "the identity of :meth:`append`"
    (raise NotImplementedError))

  (defn append [self other]
    "an associative operation for monoid"
    (raise NotImplementedError))

  (defn [classmethod] concat [cls seq]
    "fold a list using the monoid"
    (reduce cls.append seq cls.empty)))

(defn append [#* monoids]
  "the associative operation of monoid"
  (reduce (fn [m1 m2] (m1.append m2)) monoids))
(setv <> append)

(export :objects [Monoid <> append])
