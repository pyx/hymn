;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2023, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.
"hymn.operations - operations on monads"

(import
  functools [reduce]
  itertools [islice repeat]
  hy.pyops [>>]
  .types.identity [identity-m])

(require .macros [do-monad-return])

(defn first [c] (get c 0))
(defn second [c] (get c 1))
(defn empty? [coll] (= (len coll) 0))

(defn k-compose [#* monadic-funcs]
  "right-to-left Kleisli composition of monads."
  (>=> #* (reversed monadic-funcs)))
(setv <=< k-compose)

(defn k-pipe [#* monadic-funcs]
  "left-to-right Kleisli composition of monads."
  (fn [#* args #** kwargs]
    (setv [mf #* funcs] monadic-funcs)
    (reduce >> funcs (mf #* args #** kwargs))))
(setv >=> k-pipe)

(defn lift [f]
  "promote a function to a monad"
  (fn [#* args #** kwargs]
    (cond
      (and (empty? args) (empty? kwargs))
        (identity-m.unit (f))
      (empty? kwargs)
        (do-monad-return
          [unwrapped-args (sequence args)]
          (f #* unwrapped-args))
      True (do
        (setv
          keys/values (list (.items kwargs))
          keys (list (map first keys/values))
          values (sequence (map second keys/values)))
        (if (not (empty? args))
          (do-monad-return
            [unwrapped-kwargs values
             unwrapped-args (sequence args)]
            (f #* unwrapped-args #** (dict (zip keys unwrapped-kwargs))))
          (do-monad-return
            [unwrapped-kwargs values]
            (f #* [] #** (dict (zip keys unwrapped-kwargs)))))))))

(defn m-map [mf seq]
  "map monadic function :code:`mf` to a sequence, then execute that sequence
  of monadic values"
  (sequence (map mf seq)))

(defn replicate [n m]
  "perform the monadic action n times, gathering the results"
  (sequence (islice (repeat m) n)))

(defn sequence [m-values]
  "evaluate each action in the sequence, and collect the results"
  (defn collect [mlist m]
    "collect the value inside monad m into list inside mlist"
    (do-monad-return
      [value m
       value-list mlist]
      (do (.extend (setx res [value]) value-list) res)))
  (if (setx it (list m-values))
    (reduce collect (reversed it) (.unit (get it 0) []))
    (identity-m.unit [])))

(export :objects [k-compose <=< k-pipe >=> lift m-map replicate sequence])
