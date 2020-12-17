;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.
"hymn.utils - utility functions"

(defclass CachedSequence [object]
  "sequence wrapper that is lazy while keeps the items"
  (defn __init__ [self iterable]
    (setv [self._parent] (tee iterable 1)))

  (defn __iter__ [self]
    ;; fork when we need a child, never touch the first one
    (second (tee self._parent 2)))

  (defn __len__ [self]
    "return length, with side effect that it is no longer lazy"
    (-> self iter list len)))

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
  (setv [l-val r-val] (tee (repeatedly gensym))
        next-sym (next l-val))
  (yield next-sym)
  (yield init-value)
  (for [[next-sym last-sym expr] (zip l-val r-val (butlast exprs))]
    (yield next-sym)
    (yield (thread-fn last-sym expr)))
  (yield (thread-fn next-sym (last exprs))))
