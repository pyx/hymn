;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2017, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hymn.macros - monad operations implemented as macros"

(import
  [hymn.utils [thread-first thread-last thread-bindings]])

;;; lift sharp macro, e.g. #^+ => (lift +)
(defsharp ^ [f]
  (with-gensyms [lift]
    `(do (import [hymn.operations [lift :as ~lift]]) (~lift ~f))))

;;; monad return sharp macro, replaced by 'm-return, used in do-monad, e.g.
;;; (do-monad-m [a (Just 1) b #=(inc a)] #=[a b])
;;; is equivalent to
;;; (do-monad-m [a (Just 1) b (m-return (inc c))] (m-return [a b])
(defsharp = [expr] `(m-return ~expr))

(defmacro do-monad-m [binding-forms expr]
  "macro for sequencing monadic computations, a.k.a do notation in haskell"
  (when (odd? (len binding-forms))
    (macro-error None "do-monad-m binding forms must come in pairs"))
  (setv iterator (iter binding-forms))
  (setv bindings (-> (zip iterator iterator) list reversed list))
  (unless (len bindings)
    (macro-error None "do-monad-m must have at least one binding form"))
  (defn bind-action [mexpr [binding expr]]
    (if
      (= binding :when) `(if ~expr ~mexpr (. (m-return None) zero))
      (= binding :let) `(do (setv ~@expr) ~mexpr)
      (with-gensyms [monad]
        `(do
           (setv ~monad ~expr)
           (>> ~monad (fn [~binding &optional [m-return (. ~monad unit)]]
                        ~mexpr))))))
  (reduce bind-action bindings expr))

(defmacro do-monad [binding-forms expr]
  "macro for sequencing monadic computations, with automatic return"
  `(do (require hymn.macros)
     (hymn.macros.do-monad-m ~binding-forms (m-return ~expr))))

(defmacro do-monad-with [monad binding-forms expr]
  "macro for sequencing monadic composition, with said monad as default"
  `(do (require hymn.macros)
     (hymn.macros.with-monad ~monad
       (hymn.macros.do-monad ~binding-forms ~expr))))

(defmacro monad-> [init-value &rest actions]
  "threading macro for monad"
  (setv bindings (list (thread-bindings thread-first init-value actions)))
  `(do (require hymn.macros)
    (hymn.macros.do-monad-m
      [~@(butlast bindings)]
      ~(last bindings))))

(defmacro monad->> [init-value &rest actions]
  "threading tail macro for monad"
  (setv bindings (list (thread-bindings thread-last init-value actions)))
  `(do (require hymn.macros)
     (hymn.macros.do-monad-m
       [~@(butlast bindings)]
       ~(last bindings))))

(defmacro m-for [[n seq] &rest mexpr]
  "macro for sequencing monadic actions"
  (with-gensyms [m-map]
    `(do (import [hymn.operations [m-map :as ~m-map]])
       (~m-map (fn [~n] ~@mexpr) ~seq))))

(defmacro m-when [test mexpr]
  "conditional execution of monadic expressions"
  `(if ~test ~mexpr (m-return None)))

(defmacro monad-comp [expr bindings &optional condition]
  "different syntax for do notation"
  (setv guard (if (none? condition) `() `(:when ~condition)))
  `(do (require hymn.macros)
     (hymn.macros.do-monad ~(+ bindings guard) ~expr)))

(defmacro with-monad [monad &rest exprs]
  "provide default function m-return as the unit of the monad"
  `(do (setv m-return (. ~monad unit)) ~@exprs))

;;; sharp macro for the continuation monad
(require [hymn.types.continuation [<]])

;;; sharp macro for the either monad
(require [hymn.types.either [|]])

;;; macros for the lazy monad
(require [hymn.types.lazy [lazy]])

;;; sharp macro for the list monad
(require [hymn.types.list [~]])

;;; sharp macro for the maybe monad
(require [hymn.types.maybe [?]])

;;; sharp macro for the writer monad
(require [hymn.types.writer [+]])
