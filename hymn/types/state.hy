;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2015, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hymn.types.state - the state monad"

(require hymn.operations)

(import
  [operator [itemgetter]]
  [hymn.types.monad [Monad]]
  [hymn.utils [const]])

(defclass State [Monad]
  "the state monad

  computation with a shared state"
  [[--repr-- (fn [self]
               (.format "{}({})"
                        (. (type self) --name--) self.value.--name--))]
   [bind (fn [self f]
           "the bind operation of :class:`State`

           use the final state of this computation as the initial state of the
           second"
           ((type self) (fn [s]
                          (let [[(, a ns) (.run self s)]] (.run (f a) ns)))))]
   [unit (with-decorator classmethod
           (fn [cls a] "unit of state monad" (cls (fn [s] (, a s)))))]
   [evaluate (fn [self s]
               "evaluate state monad with initial state and return the result"
               (first (.run self s)))]
   [execute (fn [self s]
              "execute state monad with initial state, return the final state"
              (second (.run self s)))]
   [run (fn [self s]
          "evaluate state monad with initial state, return result and state"
          (self.value s))]])

;;; alias
(def state-m State)
(def unit State.unit)
(def evaluate State.evaluate)
(def execute State.execute)
(def run State.run)

(with-decorator State
  (defn get-state [s] "return the current state" (, s s)))
(def <-state get-state)

(defn-alias [lookup <-] [key]
  "return a monadic function that lookup the vaule with key in the state"
  (gets (itemgetter key)))

;;; gets specific component of the state, using a projection function f
(def gets get-state.fmap)

(defn modify [f]
  "maps the current state with `f` to a new state inside a state monad"
  (do-monad [s get-state _ (set-state (f s))] s))

(defn-alias [set-state state<-] [s]
  "replace the current state and return the previous one"
  (State (fn [ps] (, ps s))))

(defn set-value [key value]
  "return a monadic function that set the vaule of key in the state"
  (modify (fn [s] (doto ((type s) s) (assoc key value)))))

(defn set-values [&kwargs keys/values]
  "return a monadic function that set the vaules of keys in the state"
  (modify (fn [s] (doto ((type s) s) (.update keys/values)))))

(defn update [key f]
  "return a monadic function that update the vaule by f with key in the state"
  (do-monad
    [s get-state
     value (<- key)
     _ (set-state (doto ((type s) s) (assoc key (f value))))]
    value))

(defn update-value [key value]
  "return a monadic function that update the vaule with key in the state"
  (update key (const value)))
