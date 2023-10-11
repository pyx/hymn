;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.
"hymn.utils - utility functions"

(import itertools [islice tee])

(defclass CachedSequence [object]
  "sequence wrapper that is lazy while keeps the items"
  (defn __init__ [self iterable]
    (setv [self._parent] (tee iterable 1)))

  (defn __iter__ [self]
    ;; fork when we need a child, never touch the first one
    (get (tee self._parent 2) 1))

  (defn __len__ [self]
    "return length, with side effect that it is no longer lazy"
    (len (list (iter self)))))

(defn thread-first [sym expr]
  "insert symbol into expression as second item"
  (if (isinstance expr hy.models.Symbol)
    `(~expr ~sym)
    (let [[hd #* rest] expr] `(~hd ~sym ~@rest))))

(defn thread-last [sym expr]
  "insert symbol into expression as last item"
  (if (isinstance expr hy.models.Symbol)
    `(~expr ~sym)
    `(~@expr ~sym)))

(defn thread-bindings [thread-fn init-value exprs]
  "create a stream of symbol and expressions to be used in threading macros"
  (setv [l-val r-val] (tee (repeatedly hy.gensym))
        next-sym (next l-val)
        [#* es e] exprs)
  (yield next-sym)
  (yield init-value)
  (for [[next-sym last-sym expr] (zip l-val r-val es)]
    (yield next-sym)
    (yield (thread-fn last-sym expr)))
  (yield (thread-fn next-sym e)))

(defn constantly [c] "constant function" (fn [#* args #** kwargs] c))

(defn compose [f g]
  "function composition"
  (fn [#* args #** kwargs] (f (g #* args #** kwargs))))

(defn identity [x] "identity function" x)

(defn repeatedly [f] "repeatedly apply function f" (while True (yield (f))))
