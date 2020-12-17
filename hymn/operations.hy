;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.
"hymn.operations - operations on monads"

(import
  [hymn.types.identity [identity-m]])

(require
  [hy.extra.anaphoric [*]]
  [hymn.macros [do-monad-return]])

(defn k-compose [&rest monadic-funcs]
  "right-to-left Kleisli composition of monads."
  (>=> #* (reversed monadic-funcs)))
(setv <=< k-compose)

(defn k-pipe [&rest monadic-funcs]
  "left-to-right Kleisli composition of monads."
  (fn [&rest args &kwargs kwargs]
    (reduce >>
            (rest monadic-funcs)
            ((first monadic-funcs) #* args #** kwargs))))
(setv >=> k-pipe)

(defn lift [f]
  "promote a function to a monad"
  (fn [&rest args &kwargs kwargs]
    (if
      (and (empty? args) (empty? kwargs))
        (identity-m.unit (f))
      (empty? kwargs)
        (do-monad-return
          [unwrapped-args (sequence args)]
          (f #* unwrapped-args))
      (do
        (setv
          keys/values (list (.items kwargs))
          keys (list (map first keys/values))
          values (sequence (map second keys/values)))
        (if-not (empty? args)
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
  (sequence (take n (repeat m))))

(defn sequence [m-values]
  "evaluate each action in the sequence, and collect the results"
  (defn collect [mlist m]
    "collect the value inside monad m into list inside mlist"
    (do-monad-return
      [value m
       value-list mlist]
      ;; NOTE: cannot use cons as cons will turn None into "None"
      (doto [value] (.extend value-list))))
  (ap-if (list m-values)
    (reduce collect (reversed it) (.unit (first it) []))
    (identity-m.unit [])))
