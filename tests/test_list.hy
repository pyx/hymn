;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

(import
  [hymn.operations [replicate sequence]]
  [hymn.types [list :as list-module]]
  [hymn.types.list [list-m]])

(require
  [hymn.types.list [~]]
  [hymn.macros [do-monad-return]])

(defn test-tag-macro-list []
  "list tag macro ~ should turn a sequence into List monad"
  (assert (instance? list-m #~ (range 5)))
  (assert (= (list #~ [1 2 3 4 5]) (list (list-m [1 2 3 4 5])))))

(defn test-module-level-unit []
  "list module should have a working module level unit function"
  (assert (instance? list-m (list-module.unit None))))

(defn test-module-level-zero []
  "list module should have a module level zero"
  (assert (instance? list-m list-module.zero)))

(defn test-module-level-fmap []
  "list module should have a module level fmap and creates a list monad"
  (assert (instance? list-m (list-module.fmap identity [])))
  (assert (= [1 2 3] (list (list-module.fmap inc [0 1 2])))))

(defn test-unit-empty []
  "unit of list should accept no initial value"
  (assert (= [] (list (list-m.unit)))))

(defn test-unit-multiple-values []
  "unit of list support multiple initial values"
  (assert (= [1 2 3] (list (list-m.unit 1 2 3)))))

(defn test-zero-is-empty []
  "zero of list monad should be empty"
  (assert (empty? list-module.zero))
  (assert (empty? list-m.zero)))

(defn test-sequence-list []
  "sequence on list"
  (assert (= (list (sequence [#~ ['a 'b] #~ (range 3)]))
             [['a 0] ['a 1] ['a 2] ['b 0] ['b 1] ['b 2]])))

(defn test-do-monad-list []
  "list comprehension with do-monad-return"
  (assert (= (list (do-monad-return [x #~ ['a 'b] y #~ (range 3)] [x y]))
             [['a 0] ['a 1] ['a 2] ['b 0] ['b 1] ['b 2]])))

(defn test-do-monad-list-when []
  "list is monadplus, :when can be used in do-monad-return"
  (assert (= (list (do-monad-return
                     [a #~ [1 2] b #~ [1 2] :when (not (= a b))]
                     [a b]))
             [[1 2] [2 1]])))

(defn test-replicate-should-not-miss []
  "replicate on list monad should not miss elements"
  (setv m (list-m [0 1]))
  (assert (= (list (replicate 2 m)) [[0 0] [0 1] [1 0] [1 1]])))
