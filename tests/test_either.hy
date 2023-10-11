;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

(import
  hymn.operations [sequence]
  hymn.types.either [either-m Left Right
                     ->either to-either left? right? either failsafe])

(require
  hymn.types.either :readers [|]
  hymn.macros [do-monad-return])

(setv data 42)

(defn test-reader-macro-failsafe []
  "failsafe reader macro | should wrap a function with decorator failsafe"
  (setv failsafe-int #| int)
  (assert (isinstance (failsafe-int 1) either-m))
  (assert (= (failsafe-int 1) (either-m.unit 1))))

(defn test-zero-is-left []
  "zero of either monad should be a left"
  (assert (isinstance either-m.zero Left)))

(defn test-compare []
  "compare between either"
  (assert (= (Left data) (Left data)))
  (assert (= (Right data) (Right data)))
  (assert (!= (Left data) (Right data))))

(defn test-ordering []
  "ordering logic of either monad"
  (assert (is False (> (Left data) (Left data))))
  (assert (> (Left data) (Left (- data 1))))
  (assert (< (Left data) (Left (+ data 1))))
  (assert (is False (> (Right data) (Right data))))
  (assert (> (Right data) (Right (- data 1))))
  (assert (< (Right data) (Right (+ data 1))))
  ;; left is less then right
  (assert (< (Left data) (Right data)))
  ;; even the value inside is bigger, still
  (assert (< (Left (+ data 1)) (Right data))))

(defn test-boolean []
  "Left is falsy and Right is truthy"
  (assert (is False (bool (Left None))))
  (assert (is True (bool (Right None)))))

(defn test-from-value []
  "from-value will return Left for anything False, Right otherwise"
  (assert (isinstance (either-m.from-value None) Left))
  (assert (isinstance (either-m.from-value 0) Left))
  (assert (isinstance (either-m.from-value "") Left))
  (assert (isinstance (either-m.from-value []) Left))
  (assert (isinstance (either-m.from-value {}) Left))
  (assert (either-m.from-value 1))
  (assert (either-m.from-value (object)))
  (assert (either-m.from-value [42])))

(defn test-to-either []
  "to-either and ->either work as from-value"
  (assert (= (to-either None) (either-m.from-value None)))
  (assert (= (to-either 1) (either-m.from-value 1)))
  (assert (= (->either None) (either-m.from-value None)))
  (assert (= (->either 1) (either-m.from-value 1))))

(defn test-is-left []
  "left? testing for Left"
  (assert (left? (Left None)))
  (assert (not (left? (Right None)))))

(defn test-is-right []
  "right? testing for Right"
  (assert (right? (Right None)))
  (assert (not (right? (Left None)))))

(defn test-failsafe-decorator []
  "failsafe decorator make function return Left when exception is raised"
  (defn [failsafe] safe-div [a b] (/ a b))
  (assert (left? (safe-div 1 0)))
  (assert (= (Right 2) (safe-div 4 2)))
  (setv safe-int (failsafe int))
  (assert (= (Right 42) (safe-int "42")))
  (assert (left? (safe-int "this is no a number"))))

(defn test-do-monad-either []
  "either computation with do-monad-return"
  (assert (= (Right 3) (do-monad-return [a (Right 1) b (Right 2)] (+ a b))))
  (assert (left? (do-monad-return [a (Left 1) b (Right 0)] (/ a b))))
  (assert (left? (do-monad-return
                   [a (Right 1)
                    b (Right 0)
                    :when (not (= 0 b ))]
                    (/ a b)))))

(defn test-either-monadplus []
  "either string is monadplus"
  (assert (= (Right [1 2 3]) (sequence [(Right 1) (Right 2) (Right 3)])))
  (assert (left? (sequence [(Right 1) (Left 2) (Right 3)])))
  (assert (= (Right 1) (+ (Right 1) (Right 2))))
  (assert (= (Right 2) (+ (Left 1) (Right 2))))
  (assert (= (Right 1) (+ (Right 1) (Left 2))))
  (assert (left? (+ (Left 1) (Left 2))))
  (assert (= (Left 2) (+ (Left 1) (Left 2)))))
