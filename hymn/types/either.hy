;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2015, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hymn.types.either - the either monad"

(import
  [functools [wraps]]
  [hymn.mixins [Ord]]
  [hymn.types.monadplus [MonadPlus]])

(defreader | [f]
  (with-gensyms [failsafe]
    `(do (import [hymn.types.either [failsafe :as ~failsafe]])
       (~failsafe ~f))))

;;; NOTE:
;;; Either itself is not MonadPlus or even Monad in haskell, only Either e is
(defclass Either [MonadPlus Ord]
  "the either monad

  computation with two possibilities"
  [[--init-- (fn [self value]
               (when (is (type self) Either)
                 (raise
                   (NotImplementedError "please use Left or Right instead")))
               (.--init-- MonadPlus self value)
               nil)]
   [--lt-- (fn [self other]
             "left should always be less than right"
             (cond
               [(not (instance? (, Left Right) self))
                  (raise (TypeError "unorderable types:"
                                    (type self) (type other)))]
               ;; same monad type, compare against the value insiide
               [(is (type self) (type other)) (< self.value other.value)]
               [true (if self false true)]))]
   [bind (fn [self f]
           "the bind operation of :class:`Either`

           apply function to the value if and only if this is a
           :class:`Right`."
           (if self (f self.value) self))]
   [plus (fn [self other] (or self other))]
   [from-value (with-decorator classmethod
                 (fn [cls value]
                   "wrap ``value`` in an :class:`Either` monad

                   return a :class:`Right` if the value is evaluated as true.
                   :class:`Left` otherwise."
                   ((if value Right Left) value)))]])

(defclass Left [Either]
  "left of :class:`Either`"
  [[--bool-- (fn [self] false)]
   [--nonzero-- --bool--]
   [plus (fn [self other] other)]])

(defclass Right [Either]
  "right of :class:`Either`")

;;; we are always right!
(def Either.unit Right)
(def Either.zero (Left "unknown error"))

;;; alias
(def either-m Either)
(def unit Either.unit)
(def zero Either.zero)
(def ->either Either.from-value)
(def to-either ->either)

(defn left? [m]
  "return ``True`` if ``m`` is a :class:`Left`"
  (instance? Left m))

(defn right? [m]
  "return ``True`` if ``m`` is a :class:`Right`"
  (instance? Right m))

(defn either [handle-left handle-right m]
  "case analysis for :class:`Either`

  apply either ``handle-left`` or ``handle-right`` to ``m``
  depending on the type of it,  raise ``TypeError`` if ``m`` is not an
  :class:`Either`"
  (cond
    [(left? m) (handle-left m.value)]
    [(right? m) (handle-right m.value)]
    [true (raise (TypeError "use either on non-Either type"))]))

(defn failsafe [func]
  "decorator to turn func into monadic function of :class:`Either` monad"
  (with-decorator (wraps func)
    (fn [&rest args &kwargs kwargs]
      (try
        (Right (apply func args kwargs))
        (except [e BaseException]
          (Left e))))))
