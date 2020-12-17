;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

(import
  [hymn.operations [sequence]]
  [hymn.types [writer :as writer-module]]
  [hymn.types.writer
    [writer-m
     complex-writer-m
     decimal-writer-m
     float-writer-m
     fraction-writer-m
     list-writer-m
     int-writer-m
     string-writer-m
     tuple-writer-m
     execute run
     writer-with-type
     writer-with-type-of
     writer tell listen censor]])

(require
  [hymn.types.writer [+]]
  [hymn.macros [do-monad-return]])

(defn test-tag-macro-tell []
  "writer tag macro + should work as tell"
  (assert (= 3 (.execute (do-monad-return [_ #+ 1 _ #+ 2] None)))))

(defn test-module-level-execute []
  "writer module should have a module level execute"
  (assert (= 1 (writer-module.execute (tell 1)))))

(defn test-module-level-run []
  "writer module should have a module level run"
  (assert (= (writer-module.run (tell 1)) (.run (tell 1)))))

(defn test-writer-with-type-create-writer []
  "writer-with-type should create writer"
  (for [t [float int str]]
    (assert (issubclass (writer-with-type t) writer-m))))

(defn test-writer-with-type-correct-type []
  "writer-with-type should set the correct type on the writer created"
  (for [t [float int str]]
    (assert (instance? t (.execute (.unit (writer-with-type t) t))))))

(defn test-writer-with-type-of-create-writer []
  "writer-with-type-of should create writer"
  (for [t [1.0 1 "1"]]
    (assert (issubclass (writer-with-type-of t) writer-m))))

(defn test-writer-with-type-of-correct-type []
  "writer-with-type-of should set the correct type on the writer created"
  (for [t [1.0 1 "1"]]
    (assert
      (instance? (type t) (.execute (.unit (writer-with-type-of t) t))))))

(defn test-writer-run []
  "run unwrap the writer computation"
  (assert (= 1 (second (.run (tell 1)))))
  (assert (= "1" (second (.run (tell "1")))))
  (assert (= [] (second (.run (tell []))))))

(defn test-writer []
  "writer create a writer with value and message"
  (assert (instance? writer-m (writer None 1)))
  (assert (= (, None 1) (.run (writer None 1)))))
