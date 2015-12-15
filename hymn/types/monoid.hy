;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2015, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hymn.types.monoid - base monoid class"

(defclass Monoid [object]
  "the monoid class

  types with an associative binary operation that has an identity"
  [[empty (with-decorator property
            (fn [self]
              "the identity of ``append``"
              (raise NotImplementedError)))]
   [append (fn [self other]
             "an associative operation for monoid"
             (raise NotImplementedError))]
   [concat (with-decorator classmethod
             (fn [cls seq]
               "fold a list using the monoid"
               (reduce cls.append seq cls.empty)))]])

(defn-alias [append <>] [&rest monoids]
  "the associative operation of monoid"
  (reduce (fn [m1 m2] (m1.append m2)) monoids))
