;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2023, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.
"hymn.types.state - the state monad"

(import
  operator [itemgetter]
  ..utils [constantly]
  .monad [Monad])

(require hymn.macros [do-monad-return])

(defclass State [Monad]
  "the state monad

  computation with a shared state"
  (defn __repr__ [self]
    (.format "{}({})" (. (type self) __name__) (. self.value __name__)))

  (defn bind [self f]
    "the bind operation of :class:`State`

    use the final state of this computation as the initial state of the
    second"
    ((type self) (fn [s] (setv #(a ns) (.run self s)) (.run (f a) ns))))

  (defn [classmethod] unit [cls a]
    "the unit of state monad"
    (cls (fn [s] #(a s))))

  (defn evaluate [self s]
    "evaluate state monad with initial state and return the result"
    (get (.run self s) 0))

  (defn execute [self s]
    "execute state monad with initial state, return the final state"
    (get (.run self s) 1))

  (defn run [self s]
    "evaluate state monad with initial state, return result and state"
    (self.value s)))

(defn [State] get-state [s] "return the current state" #(s s))

(defn lookup [key]
  "return a monadic function that lookup the vaule with key in the state"
  (gets (itemgetter key)))

;; gets specific component of the state, using a projection function f
(setv gets get-state.fmap)

(defn modify [f]
  "maps the current state with `f` to a new state inside a state monad"
  (do-monad-return [s get-state _ (set-state (f s))] s))

(defn set-state [s]
  "replace the current state and return the previous one"
  (State (fn [ps] #(ps s))))

(defn set-value [key value]
  "return a monadic function that set the vaule of key in the state"
  (modify (fn [s] (setv m ((type s) s) (get m key) value) m)))

(defn set-values [#** keys/values]
  "return a monadic function that set the vaules of keys in the state"
  (modify (fn [s] (setv m ((type s) s)) (.update m keys/values) m)))

(defn update [key f]
  "return a monadic function that update the vaule by f with key in the state"
  (do-monad-return
    [s get-state
     value (<- key)
     _ (set-state (do (setv m ((type s) s) (get m key) (f value)) m))]
    value))

(defn update-value [key value]
  "return a monadic function that update the vaule with key in the state"
  (update key (constantly value)))

;; alias
(setv state-m State
      <-state get-state
      <- lookup
      state<- set-state)

(export
  :objects [state-m State
            get-state <-state
            lookup <-
            gets
            modify
            set-state state<-
            set-value set-values
            update update-value])
