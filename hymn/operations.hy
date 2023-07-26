;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.
"hymn.operations - operations on monads"

(import
  functools [reduce]
  hymn.types.identity [identity-m]
  hymn.utils [empty?]
  hyrule.iterables [rest])

(require
  hymn.macros [do-monad-return]
  hyrule.anaphoric [ap-if]
  hyrule.argmove [doto])

(defn k-compose [&rest monadic-funcs]
  "right-to-left Kleisli composition of monads."
  (>=> #* (reversed monadic-funcs)))
(setv <=< k-compose)

(defn k-pipe [#* monadic-funcs]
  "left-to-right Kleisli composition of monads."
  (fn [#* args #** kwargs]
    (reduce >>
            (rest monadic-funcs)
            ((get monadic-funcs 0) #* args #** kwargs))))
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
          keys (list (map next keys/values))
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
    (reduce collect (reversed it) (.unit (get it 0) []))
    (identity-m.unit [])))
