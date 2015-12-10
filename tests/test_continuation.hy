;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2015, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.

(import
  [hymn.types [continuation :as continuation-module]]
  [hymn.types.continuation [cont-m call-cc]])

(require hymn.types.continuation)
(require hymn.operations)

(defn test-reader-macro-continuation-unit []
  "unit reader macro < should work as cont-m.unit"
  (assert (= -1 (.run (do-monad [a #<1 b #<2] (- a b))))))

(defn test-module-level-unit []
  "continuation module should have a working module level unit function"
  (assert (instance? cont-m (continuation-module.unit identity))))

(defn test-module-level-run []
  "continuation module should have a module level run"
  (def c (cont-m.util nil))
  (assert (= (continuation-module.run c) (.run c))))

(defn test-continuation-run []
  "run the continuation"
  (assert (= -1 (.run (do-monad [a #<1 b #<2] (- a b))))))

(defn test-call-with-conintuation []
  "call with current continuation should capture a continuation"
  (assert (instance? cont-m (call-cc identity)))
  (def c [])
  (def 1-2 (do-monad [a #<1 b (call-cc (fn [k] (c.append k) (k 2)))] (- a b)))
  (assert (empty? c))
  (assert (= -1 (.run 1-2)))
  (assert (= 1 (len c)))
  (def 1- (.pop c))
  (assert (instance? cont-m (1- 1)))
  (assert (= 0 (.run (1- 1))))
  (assert (= 42 (.run (1- -41)))))
