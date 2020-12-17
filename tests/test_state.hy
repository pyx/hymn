;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

(import
  [hymn.operations [sequence]]
  [hymn.types [state :as state-module]]
  [hymn.types.state
    [state-m
     get-state <-state
     lookup <-
     gets
     modify
     set-state state<-
     set-value
     set-values
     update
     update-value]])

(require hymn.operations)

(setv env {'a 42 'b None 'c "hello"})

(defn test-module-level-unit []
  "state module should have a working module level unit function"
  (assert (instance? state-m (state-module.unit True))))

(defn test-module-level-run []
  "state module should have a module level run"
  (setv v (object)
        s (object)
        m (state-m.unit v))
  (assert (= (.run m s) (state-module.run m s))))

(defn test-module-level-evaluate []
  "state module should have a module level evaluate"
  (setv v (object)
        s (object)
        m (state-m.unit v))
  (assert (= (.evaluate m s) (state-module.evaluate m s))))

(defn test-module-level-execute []
  "state module should have a module level execute"
  (setv v (object)
        s (object)
        m (state-m.unit v))
  (assert (= (.execute m s) (state-module.execute m s))))

(defn test-run []
  "run should return the result and state"
  (setv v (object)
        s (object))
  ;; this test implies the structure of the value inside state monad
  (assert (= (, v s) (.run (state-m.unit v) s))))

(defn test-evaluate []
  "evaluate should run the state monad and return the result"
  (setv v (object)
        s (object))
  (assert (= v (.evaluate (state-m.unit v) s))))

(defn test-execute []
  "execute should run the state monad and return the final state"
  (setv v (object)
        s (object))
  (assert (= s (.execute (state-m.unit v) s))))

(defn test-get-state []
  "get-state should return the current state as the result"
  (setv s (object)
        m (state-m.unit True))
  (assert (instance? state-m get-state))
  (assert (is s (.evaluate get-state s) (.evaluate <-state s))))

(defn test-lookup []
  "lookup should get a value from state by the key"
  (assert (instance? state-m (lookup 1)))
  (assert (instance? state-m (<- 1)))
  (setv s {'a (object)  'b (object)  'c (object)})
  (for [key s]
    (assert (= (get s key) (.evaluate (lookup key) s) (.evaluate (<- key) s))))
  (setv keys (.keys s))
  (assert (= (lfor key keys (get s key))
             (.evaluate (sequence (map <- keys)) s))))

(defn test-gets []
  "gets should get component of the state using a projection function"
  (defn get-a [s] (get s 'a))
  (defn get-b [s] (get s 'b))
  (setv s {'a (object)  'b (object)  'c (object)})
  (assert (instance? state-m (gets get-a)))
  (assert (= (get-a s) (.evaluate (gets get-a) s)))
  (assert (= (get-b s) (.evaluate (gets get-b) s)))
  (assert (= (len s) (.evaluate (gets len) s))))

(defn test-modify []
  "modify should change the state with function"
  (setv obj-a (object)
        new-obj-a (object)
        s {'a obj-a}
        change-a (modify (fn [s] (assoc s 'a new-obj-a))))
  (assert (instance? state-m change-a))
  (assert (is-not obj-a (get (.evaluate change-a s) 'a)))
  (assert (is new-obj-a (get s 'a))))

(defn test-set-state []
  "set-state should replace the current state and return the previous one"
  (setv s (object)
        ns (object))
  (assert (instance? state-m (set-state ns)))
  (assert (instance? state-m (state<- ns)))
  (assert (is s (.evaluate (set-state ns) s) (.evaluate (state<- ns) s)))
  (assert (is ns (.execute (set-state ns) s) (.execute (state<- ns) s))))

(defn test-set-value []
  "set-value should set the value in the state with the key"
  (setv s {'a 1  'b 2})
  (assert (instance? state-m (set-value 'a 3)))
  (assert (= 3 (get (.execute (set-value 'a 3) s) 'a)))
  (assert (= 1 (get s 'a))))

(defn test-set-values []
  "set-values should change values with keys"
  (setv s {})
  (assert (instance? state-m (set-values :a 1 :b 2)))
  (assert (= {'a 1 'b 2} (.execute (set-values :a 1 :b 2) s)))
  (assert (= s {})))

(defn test-update []
  "update should change the value associated by key with function"
  (setv s {'a 1})
  (assert (instance? state-m (update 'a inc)))
  (assert (= 2 (get (.execute (update 'a inc) s) 'a)))
  (assert (= s {'a 1})))

(defn test-update-value []
  "update should set the value with key"
  (setv s {'a 1})
  (assert (instance? state-m (update-value 'a 2)))
  (assert (= 2 (get (.execute (update-value 'a 2) s) 'a)))
  (assert (= s {'a 1})))
