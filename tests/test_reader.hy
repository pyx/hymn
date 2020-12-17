;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

(import
  [hymn.operations [sequence]]
  [hymn.types [reader :as reader-module]]
  [hymn.types.reader [reader-m asks reader ask local lookup <-]])

(require hymn.operations)

(setv env {'a 42 'b None 'c "hello"})

(defn test-module-level-unit []
  "reader module should have a working module level unit function"
  (assert (instance? reader-m (reader-module.unit identity))))

(defn test-module-level-run []
  "reader module should have a module level run"
  (assert (reader-module.run (reader-m.unit True) None)))

(defn test-asks-and-reader-create-reader []
  "asks and reader should create a reader from function"
  (assert (instance? reader-m (asks identity)))
  (assert (instance? reader-m (reader identity))))

(defn test-asks-and-reader []
  "asks and reader create a function for the environment"
  (assert (= (.run (asks (fn [e] (get e 'a))) env)
             (get env 'a)))
  (assert (= (.run (asks (fn [e] (len e))) env)
             (len env)))
  (assert (= (.run (reader (fn [e] (get e 'b))) env)
             (.run (asks (fn [e] (get e 'b))) env))))

(defn test-ask []
  "ask return the environment"
  (assert (is env (.run ask env))))

(defn test-local []
  "local should run a computation in a possibly modified environment"
  (assert (is-not env (.run ((local dict) ask) env)))
  (assert (= 12 (.run ((local (fn [e] 12)) ask) env))))

(defn test-lookup []
  "lookup get a value from environment by the key"
  (for [key env]
    (assert (= (.run (lookup key) env) (get env key)))
    (assert (= (.run (lookup key) env) (.run (<- key) env))))
  (setv keys (.keys env))
  (assert (= (lfor key keys (get env key))
             (.run (sequence (map <- keys)) env))))
