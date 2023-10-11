;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2023, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

(import
  hymn.operations [sequence]
  hymn.types [maybe :as maybe-module]
  hymn.types.maybe [maybe-m Just Nothing nothing? maybe])

(require
  hymn.types.maybe :readers [?]
  hymn.macros [do-monad-return])

(defn test-reader-macro-maybe []
  "maybe reader macro ? should wrap a function with decorator maybe"
  (setv maybe-int #? int)
  (assert (isinstance (maybe-int 1) maybe-m))
  (assert (= (maybe-int 1) (maybe-m.unit 1))))

(defn test-module-level-from-maybe []
  "maybe module should have a module level from-maybe"
  (assert (= 1 (maybe-module.from-maybe (Just 1) 2)))
  (assert (= 2 (maybe-module.from-maybe Nothing 2)))
  (assert (= 1 (maybe-module.<-maybe (Just 1) 2))
  (assert (= 2 (maybe-module.<-maybe Nothing 2)))))

(defn test-module-level-to-maybe []
  "maybe module should have a module level to-maybe"
  (assert (= (Just 1) (maybe-module.to-maybe 1)))
  (assert (= (Just 1) (maybe-module.->maybe 1)))
  (assert (is Nothing (maybe-module.to-maybe None)))
  (assert (is Nothing (maybe-module.->maybe None))))

(defn test-zero-is-nothing []
  "zero of maybe monad should be Nothing"
  (assert (is maybe-m.zero Nothing)))

(defn test-type []
  "Nothing and Just are of maybe monad"
  (assert (isinstance Nothing maybe-m))
  (assert (isinstance (Just None) maybe-m))
  (assert (not (isinstance Nothing Just))))

(defn test-compare []
  "compare between maybe"
  (assert (= Nothing Nothing))
  (assert (= (Just 42) (Just 42)))
  (assert (!= (Just None) Nothing))
  (assert (!= Nothing (Just None)))
  (assert (is Nothing Nothing)))

(defn test-ordering []
  "ordering logic of maybe monad"
  (assert (is False (> Nothing Nothing)))
  (assert (is False (< Nothing Nothing)))
  (assert (is False (> Nothing (Just None))))
  (assert (< Nothing (Just None)))
  (assert (> (Just None) Nothing))
  (assert (> (Just 1) (Just 0)))
  (assert (>= (Just 1) (Just 1)))
  (assert (= (Just 1) (Just 1))))

(defn test-boolean []
  "Nothing is falsy and Just is truthy"
  (assert (is False (bool Nothing)))
  (assert (is True (bool (Just None)))))

(defn test-from-value []
  "from-value will return Nothing for anything False, Just otherwise"
  (assert (is Nothing (maybe-m.from-value None)))
  (assert (is Nothing (maybe-m.from-value 0)))
  (assert (is Nothing (maybe-m.from-value "")))
  (assert (is Nothing (maybe-m.from-value [])))
  (assert (is Nothing (maybe-m.from-value {})))
  (assert (isinstance (maybe-m.from-value 1) Just))
  (assert (isinstance (maybe-m.from-value (object)) Just))
  (assert (isinstance (maybe-m.from-value [42]) Just)))

(defn test-from-maybe []
  "from-maybe should get the value from Just and return default otherwise"
  (assert (= 1 (.from-maybe (Just 1) None)))
  (assert (is None (.from-maybe (Just None) 1)))
  (assert (= 1 (.from-maybe Nothing 1)))
  (assert (is None (.from-maybe Nothing None))))

(defn test-is-nothing []
  "nothing? testing for Nothing"
  (assert (nothing? Nothing))
  (assert (not (nothing? (Just None)))))

(defn test-maybe-decorator []
  "maybe decorator make function return Nothing when exception is raised"
  (defn [maybe] safe-div [a b] (/ a b))
  (assert (is Nothing (safe-div 1 0)))
  (assert (= (Just 2) (safe-div 4 2)))
  (setv safe-int (maybe int))
  (assert (= (Just 42) (safe-int "42")))
  (assert (is Nothing (safe-int "this is no a number"))))

(defn test-do-monadaybe []
  "maybe computation with do-monad-return"
  (assert (= (Just 3) (do-monad-return [a (Just 1) b (Just 2)] (+ a b)))))

(defn test-do-monadaybe-when []
  "maybe is monadplus, :when can be used in do-monad-return"
  (assert (is Nothing
            (do-monad-return
              [a (Just 1)
               b (Just 0)
              :when (not (= 0 b))]
              (/ a b)))))

(defn test-maybe-monadplus []
  "maybe is monadplus"
  (assert (= (Just [1 2 3]) (sequence [(Just 1) (Just 2) (Just 3)])))
  (assert (is Nothing (sequence [(Just 1) Nothing (Just 3)])))
  (assert (= (Just 1) (+ (Just 1) (Just 2))))
  (assert (= (Just 1) (+ Nothing (Just 1))))
  (assert (= (Just 1) (+ (Just 1) Nothing)))
  (assert (is Nothing (+ Nothing Nothing))))
