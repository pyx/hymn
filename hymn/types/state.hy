;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.
"hymn.types.state - the state monad"

(import
  [operator [itemgetter]]
  [hymn.types.monad [Monad]])

(require [hymn.macros [do-monad-return]])

(defclass State [Monad]
  "the state monad

  computation with a shared state"
  (defn __repr__ [self]
    (.format "{}({})" (name (type self)) (name self.value)))

  (defn bind [self f]
    "the bind operation of :class:`State`

    use the final state of this computation as the initial state of the
    second"
    ((type self) (fn [s] (setv (, a ns) (.run self s)) (.run (f a) ns))))

  (with-decorator classmethod
    (defn unit [cls a] "the unit of state monad" (cls (fn [s] (, a s)))))

  (defn evaluate [self s]
    "evaluate state monad with initial state and return the result"
    (first (.run self s)))

  (defn execute [self s]
    "execute state monad with initial state, return the final state"
    (second (.run self s)))

  (defn run [self s]
    "evaluate state monad with initial state, return result and state"
    (self.value s)))

;; alias
(setv state-m State
      unit State.unit
      evaluate State.evaluate
      execute State.execute
      run State.run)

(with-decorator State
  (defn get-state [s] "return the current state" (, s s)))
(setv <-state get-state)

(defn lookup [key]
  "return a monadic function that lookup the vaule with key in the state"
  (gets (itemgetter key)))
(setv <- lookup)

;; gets specific component of the state, using a projection function f
(setv gets get-state.fmap)

(defn modify [f]
  "maps the current state with `f` to a new state inside a state monad"
  (do-monad-return [s get-state _ (set-state (f s))] s))

(defn set-state [s]
  "replace the current state and return the previous one"
  (State (fn [ps] (, ps s))))
(setv state<- set-state)

(defn set-value [key value]
  "return a monadic function that set the vaule of key in the state"
  (modify (fn [s] (doto ((type s) s) (assoc key value)))))

(defn set-values [&kwargs keys/values]
  "return a monadic function that set the vaules of keys in the state"
  (modify (fn [s] (doto ((type s) s) (.update keys/values)))))

(defn update [key f]
  "return a monadic function that update the vaule by f with key in the state"
  (do-monad-return
    [s get-state
     value (<- key)
     _ (set-state (doto ((type s) s) (assoc key (f value))))]
    value))

(defn update-value [key value]
  "return a monadic function that update the vaule with key in the state"
  (update key (constantly value)))
