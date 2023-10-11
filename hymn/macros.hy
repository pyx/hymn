;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.
"hymn.macros - monad operations implemented as macros"

(import
  functools [reduce]
  .utils [repeatedly thread-first thread-last thread-bindings])

;; lift reader macro, e.g. #^ + => (lift +)
(defreader ^ (setv f (.parse-one-form &reader))
  `(hy.M.hymn.operations.lift ~f))

;; monad return reader macro, replaced by 'm-return, used in do-monad,
;; e.g.
;; (do-monad [a (Just 1) b #= (inc a)] #= [a b])
;; is equivalent to
;; (do-monad [a (Just 1) b (m-return (inc c))] (m-return [a b])
(defreader = (setv expr (.parse-one-form &reader)) `(m-return ~expr))

(defmacro do-monad [binding-forms expr]
  "macro for sequencing monadic computations, a.k.a do notation in haskell"
  (when (= 1 (% (len binding-forms) 2))
    (macro-error None "do-monad binding forms must come in pairs"))
  (setv iterator (iter binding-forms)
        bindings (list (reversed (list (zip iterator iterator)))))
  (when (not (len bindings))
    (macro-error None "do-monad must have at least one binding form"))
  (defn bind-action [mexpr actions]
    (setv [binding expr] actions)
    (cond
      (= binding :when) `(if ~expr ~mexpr (. (m-return None) zero))
      (= binding :let) `(do (setv ~@expr) ~mexpr)
      True (let [monad (hy.gensym)
                 m (hy.gensym)]
             `(do
                (setv ~monad ~expr)
                (>> ~monad
                    (fn [~m [m-return (. ~monad unit)]]
                      ;; function arguments cannot be unpacked inline, use
                      ;; setv here in case the binding contains structure,
                      ;; e.g [a b]
                      (setv ~binding ~m)
                      ~mexpr))))))
  (reduce bind-action bindings expr))

(defmacro do-monad-return [binding-forms expr]
  "macro for sequencing monadic computations, with automatic return"
  `(do (require hymn.macros)
     (hymn.macros.do-monad ~binding-forms (m-return ~expr))))

(defmacro do-monad-with [monad binding-forms expr]
  "macro for sequencing monadic composition, with said monad as default"
  `(do (require hymn.macros)
     (hymn.macros.with-monad ~monad
       (hymn.macros.do-monad-return ~binding-forms ~expr))))

(defmacro monad-> [init-value #* actions]
  "threading macro for monad"
  (setv
    [#* bindings e] (list (thread-bindings thread-first init-value actions)))
  `(do (require hymn.macros)
    (hymn.macros.do-monad
      [~@bindings]
      ~e)))

(defmacro monad->> [init-value #* actions]
  "threading tail macro for monad"
  (setv
    [#* bindings e] (list (thread-bindings thread-last init-value actions)))
  `(do (require hymn.macros)
     (hymn.macros.do-monad
       [~@bindings]
       ~e)))

(defmacro m-for [forms #* mexpr]
  "macro for sequencing monadic actions"
  (setv [n seq] forms)
  `(hy.M.hymn.operations.m-map (fn [~n] ~@mexpr) ~seq))

(defmacro m-when [test mexpr]
  "conditional execution of monadic expressions"
  `(if ~test ~mexpr (m-return None)))

(defmacro monad-comp [expr bindings [condition None]]
  "different syntax for do notation"
  (setv guard (if (is None condition) `() `(:when ~condition)))
  `(do (require hymn.macros)
     (hymn.macros.do-monad-return ~(+ bindings guard) ~expr)))

(defmacro with-monad [monad #* exprs]
  "provide default function m-return as the unit of the monad"
  `(do (setv m-return (. ~monad unit)) ~@exprs))

(export
  :macros [do-monad do-monad-return do-monad-with
           monad-> monad->>
           m-for m-when
           monad-comp
           with-monad])
