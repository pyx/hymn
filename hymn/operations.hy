;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2017, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hymn.operations - operations on monads"

(import
  [hymn.types.identity [identity-m]]
  [hymn.utils [apply]])

(require
  [hy.extra.anaphoric [*]]
  [hymn.macros [do-monad]])

(defn k-compose [&rest monadic-funcs]
  "right-to-left Kleisli composition of monads."
  (apply >=> (reversed monadic-funcs)))
(setv <=< k-compose)

(defn k-pipe [&rest monadic-funcs]
  "left-to-right Kleisli composition of monads."
  (fn [&rest args &kwargs kwargs]
    (reduce (fn [m f] (>> m f))
            (rest monadic-funcs)
            (apply (first monadic-funcs) args kwargs))))
(setv >=> k-pipe)

(defn lift [f]
  "promote a function to a monad"
  (fn [&rest args &kwargs kwargs]
    (if
      (and (empty? args) (empty? kwargs))
        (identity-m.unit (f))
      (empty? kwargs)
        (do-monad [unwrapped-args (sequence args)] (apply f unwrapped-args))
      (do
        (setv
          keys/values (list (.items kwargs))
          keys (list (map first keys/values))
          values (sequence (map second keys/values)))
        (if-not (empty? args)
          (do-monad
            [unwrapped-kwargs values
             unwrapped-args (sequence args)]
            (apply f unwrapped-args (dict (zip keys unwrapped-kwargs))))
          (do-monad
            [unwrapped-kwargs values]
            (apply f [] (dict (zip keys unwrapped-kwargs)))))))))

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
    (do-monad
      [value m
       value-list mlist]
      ;; NOTE: cannot use cons as cons will turn None into "None"
      (doto [value] (.extend value-list))))
  (ap-if (list m-values)
    (reduce collect (reversed it) (.unit (first it) []))
    (identity-m.unit [])))
