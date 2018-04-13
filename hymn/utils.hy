;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2017, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hymn.utils - utility functions"

(import [itertools [tee]])

(defclass CachedSequence [object]
  "sequence wrapper that is lazy while keeps the items"
  (defn --init-- [self iterable]
    (setv [self._parent] (tee iterable 1)))

  (defn --iter-- [self]
    ;; fork when we need a child, never touch the first one
    (second (tee self._parent 2)))

  (defn --len-- [self]
    "return length, with side effect that it is no longer lazy"
    (-> self iter list len)))

(defclass SuppressContextManager [object]
  "context manager that suppress specified exceptions"
  (defn --init-- [self exceptions]
    (when (any (genexpr ex [ex exceptions]
                 (not (issubclass ex BaseException))))
      (raise
        (TypeError "must be a subclass of BaseException")))
      (setv self.exceptions (tuple exceptions)))

  (defn --enter-- [self] None)

  (defn --exit-- [self exc-type exc-val exc-tb]
    (instance? self.exceptions exc-val)))

(try (import [contextlib [suppress]])
  (except [ImportError]
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
  (setv [l-val r-val] (tee (repeatedly gensym)))
  (setv next-sym (next l-val))
  (yield next-sym)
  (yield init-value)
  (for [[next-sym last-sym expr] (zip l-val r-val (butlast exprs))]
    (yield next-sym)
    (yield (thread-fn last-sym expr)))
  (yield (thread-fn next-sym (last exprs))))
