;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2023, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

(import
  hymn.operations [sequence]
  hymn.types.writer [writer-m
                     complex-writer-m
                     decimal-writer-m
                     float-writer-m
                     fraction-writer-m
                     list-writer-m
                     int-writer-m
                     string-writer-m
                     tuple-writer-m
                     writer-with-type
                     writer-with-type-of
                     writer tell listen censor])

(require
  hymn.types.writer :readers [+]
  hymn.macros [do-monad-return])

(defn test-reader-macro-tell []
  "writer reader macro + should work as tell"
  (assert (= 3 (.execute (do-monad-return [_ #+ 1 _ #+ 2] None)))))

(defn test-writer-with-type-create-writer []
  "writer-with-type should create writer"
  (for [t [float int str]]
    (assert (issubclass (writer-with-type t) writer-m))))

(defn test-writer-with-type-correct-type []
  "writer-with-type should set the correct type on the writer created"
  (for [t [float int str]]
    (assert (isinstance (.execute (.unit (writer-with-type t) t)) t))))

(defn test-writer-with-type-of-create-writer []
  "writer-with-type-of should create writer"
  (for [t [1.0 1 "1"]]
    (assert (issubclass (writer-with-type-of t) writer-m))))

(defn test-writer-with-type-of-correct-type []
  "writer-with-type-of should set the correct type on the writer created"
  (for [t [1.0 1 "1"]]
    (assert
      (isinstance (.execute (.unit (writer-with-type-of t) t)) (type t)))))

(defn test-writer-run []
  "run unwrap the writer computation"
  (assert (= 1 (get (.run (tell 1)) 1)))
  (assert (= "1" (get (.run (tell "1")) 1)))
  (assert (= [] (get (.run (tell [])) 1))))

(defn test-writer []
  "writer create a writer with value and message"
  (assert (isinstance (writer None 1) writer-m))
  (assert (= #(None 1) (.run (writer None 1)))))
