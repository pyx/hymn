;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2023, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

(import hymn.types.continuation [cont-m call-cc])

(require
  hymn.types.continuation :readers [<]
  hymn.macros [do-monad-return])

(defn test-reader-macro-continuation-unit []
  "unit reader macro < should work as cont-m.unit"
  (assert (= -1 (.run (do-monad-return [a #< 1 b #< 2] (- a b))))))

(defn test-continuation-run []
  "run the continuation"
  (assert (= -1 (.run (do-monad-return [a #< 1 b #< 2] (- a b))))))

(defn test-call-with-conintuation []
  "call with current continuation should capture a continuation"
  (assert (isinstance (call-cc (fn [x] x)) cont-m))
  (setv c []
        1-2 (do-monad-return
              [a #< 1 b (call-cc (fn [k] (c.append k) (k 2)))]
              (- a b)))
  (assert (= 0 (len c)))
  (assert (= -1 (.run 1-2)))
  (assert (= 1 (len c)))
  (setv 1- (.pop c))
  (assert (isinstance (1- 1) cont-m))
  (assert (= 0 (.run (1- 1))))
  (assert (= 42 (.run (1- -41)))))
