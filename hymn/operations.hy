;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2015, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hymn.operations - operations on monads"

(import
  [hymn.types.identity [identity-m]])

(require hy.contrib.anaphoric)

;;; lift reader macro, e.g. #^+ => (lift +)
(defreader ^ [f]
  (with-gensyms [lift]
    `(do (import [hymn.operations [lift :as ~lift]]) (~lift ~f))))

;;; monad return reader macro, replaced by 'm-return, used in do-monad, e.g.
;;; (do-monad-m [a (Just 1) b #=(inc a)] #=[a b])
;;; is equivalent to
;;; (do-monad-m [a (Just 1) b (m-return (inc c))] (m-return [a b])
(defreader = [expr] `(m-return ~expr))

(defmacro do-monad-m [binding-forms expr]
  "macro for sequencing monadic computations, a.k.a do notation in haskell"
  (when (odd? (len binding-forms))
    (macro-error nil "do-monad-m binding forms must come in pairs"))
  (def iterator (iter binding-forms))
  (def bindings (-> (zip iterator iterator) list reversed list))
  (unless (len bindings)
    (macro-error nil "do-monad-m must have at least one binding form"))
  (defn bind-action [mexpr [binding expr]]
    (cond
      [(= binding :when)
        `(if ~expr ~mexpr (. (m-return nil) zero))]
      [(= binding :let)
        `(let ~expr ~mexpr)]
      [true
        (with-gensyms [monad]
          `(let [[~monad ~expr]]
             (>> ~monad (fn [~binding &optional [m-return (. ~monad unit)]]
                          ~mexpr))))]))
  (reduce bind-action bindings expr))

(defmacro do-monad [binding-forms expr]
  "macro for sequencing monadic computations, with automatic return"
  `(do-monad-m ~binding-forms (m-return ~expr)))

(defmacro do-monad-with [monad binding-forms expr]
  "macro for sequencing monadic composition, with said monad as default"
  `(with-monad ~monad (do-monad ~binding-forms ~expr)))

(defmacro m-for [[n seq] &rest mexpr]
  "macro for sequencing monadic actions"
  (with-gensyms [m-map]
    `(do (import [hymn.operations [m-map :as ~m-map]])
       (~m-map (fn [~n] ~@mexpr) ~seq))))

(defmacro m-when [test mexpr]
  "conditional execution of monadic expressions"
  `(if ~test ~mexpr (m-return nil)))

(defmacro with-monad [monad &rest exprs]
  "provide default function m-return as the unit of the monad"
  `(let [[m-return (. ~monad unit)]] ~@exprs))

(defn-alias [k-compose <=<] [&rest monadic-funcs]
  "right-to-left Kleisli composition of monads."
  (apply >=> (reversed monadic-funcs)))

(defn-alias [k-pipe >=>] [&rest monadic-funcs]
  "left-to-right Kleisli composition of monads."
  (fn [&rest args &kwargs kwargs]
    (reduce (fn [m f] (>> m f))
            (rest monadic-funcs)
            (apply (first monadic-funcs) args kwargs))))

(defn lift [f]
  "promote a function to a monad"
  (fn [&rest args &kwargs kwargs]
    (cond
      [(and (empty? args) (empty? kwargs))
       (identity-m.unit (f))]
      [(empty? kwargs)
       (do-monad [unwrapped-args (sequence args)] (apply f unwrapped-args))]
      [true
       (do
         (def keys/values (list (.items kwargs)))
         (def keys (list (map first keys/values)))
         (def values (sequence (map second keys/values)))
         (if-not (empty? args)
           (do-monad
             [unwrapped-kwargs values
              unwrapped-args (sequence args)]
             (apply f unwrapped-args (dict (zip keys unwrapped-kwargs))))
           (do-monad
             [unwrapped-kwargs values]
             (apply f [] (dict (zip keys unwrapped-kwargs))))))])))

(defn m-map [mf seq]
  "map monadic function ``mf`` to a sequence, then execute that sequence of
  monadic values"
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
      ;; NOTE: cannot use cons as cons will turn nil/None into "None"
      (doto [value] (.extend value-list))))
  (ap-if (list m-values)
    (reduce collect (reversed it) (.unit (first it) []))
    (identity-m.unit [])))
