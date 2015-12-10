;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2015, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.

(defmacro m= [m1 m2]
  `(= (run ~m1) (run ~m2)))

(def data 42)

(defn test-fmap [monad-runner]
  "bind should apply function to the value inside the monad"
  (def [monad run] monad-runner)
  (assert (m= (.fmap (monad.unit data) inc) (monad.unit (inc data)))))

(defn test-first-functor-law [monad-runner]
  "monad should satisfy first functor law: fmap id == id"
  (def [monad run] monad-runner)
  (def m (monad.unit data))
  (assert (m= (m.fmap identity) m)))

(defn test-second-functor-law [monad-runner]
  "monad should satisfy second functor law: fmap (f . g) == fmap f . fmap g"
  (def [monad run] monad-runner)
  (def m (monad.unit data))
  (def f inc)
  (def g (fn [n] (* n 2)))
  (def f-g (fn [n] (f (g n))))
  ;; make sure the order is significant
  (assert (!= (f (g data)) (g (f data))))
  (assert (m= (.fmap m f-g) (-> m (.fmap g) (.fmap f)))))
