;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2016, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hymn.utils - utility functions"

(import [itertools [tee]])

(defclass CachedSequence [object]
  "sequence wrapper that is lazy while keeps the items"
  [[--init-- (fn [self iterable]
               (def [self._parent] (tee iterable 1))
               nil)]
   [--iter-- (fn [self]
               ;; fork when we need a child, never touch the first one
               (second (tee self._parent 2)))]
   [--len-- (fn [self]
              "return length, with side effect that it is no longer lazy"
              (-> self iter list len))]])

(try (import [contextlib [suppress]])
  (except [ImportError]
    (defclass SuppressContextManager [object]
      "context manager that suppress specified exceptions"
      [[--init-- (fn [self exceptions]
                   (when (any (genexpr ex [ex exceptions]
                                (not (issubclass ex BaseException))))
                     (raise
                       (TypeError "must be a subclass of BaseException")))
                   (setv self.exceptions (tuple exceptions))
                   nil)]
      [--enter-- (fn [self] nil)]
      [--exit-- (fn [self exc-type exc-val exc-tb]
                  (instance? self.exceptions exc-val))]])

    (defn suppress [&rest exceptions]
      "suppress specified exceptions"
      (unless exceptions
        (raise (RuntimeError "no exception specified")))
      (SuppressContextManager exceptions))))

(defn thread-first [sym expr]
  "insert symbol into expression as second item"
  (if (symbol? expr)
    `(~expr ~sym)
    `(~(first expr) ~sym ~@(rest expr))))

(defn thread-last [sym expr]
  "insert symbol into expression as last item"
  (if (symbol? expr)
    `(~expr ~sym)
    `(~@expr ~sym)))

(defn thread-bindings [thread-fn init-value exprs]
  "create a stream of symbol and expressions to be used in threading macros"
  (def [l-val r-val] (tee (repeatedly gensym)))
  (def next-sym (next l-val))
  (yield next-sym)
  (yield init-value)
  (for [[next-sym last-sym expr] (zip l-val r-val (butlast exprs))]
    (yield next-sym)
    (yield (thread-fn last-sym expr)))
  (yield (thread-fn next-sym (last exprs))))

;;; These should be in standard library, I re-implemented them everytime.
(defn compose [&rest fs]
  "function composition"
  (defn compose-2 [f g]
    "compose 2 functions"
    (fn [&rest args &kwargs kwargs]
      (f (apply g args kwargs))))
  (reduce compose-2 fs))

(defn const [value]
  "constant function"
  (defn constant [&rest args &kwargs kwargs] value)
  (setv constant.--doc-- (+ "constant fucntion of " (str value)))
  constant)

(defn pipe (&rest fs)
  "reversed function composition"
  (apply compose (reversed fs)))
