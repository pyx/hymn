;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2023, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.
"hymn.types.either - the either monad"

(import
  functools [wraps]
  ..mixins [Ord]
  .monadplus [MonadPlus])

(defreader | (setv f (.parse-one-form &reader))
  `(hy.M.hymn.types.either.failsafe ~f))

;; NOTE:
;; Either itself is not MonadPlus or even Monad in haskell, only Either e is
(defclass Either [MonadPlus Ord]
  "the either monad

  computation with two possibilities"
  (defn __init__ [self value]
    (when (is (type self) Either)
      (raise (NotImplementedError "please use Left or Right instead")))
      (.__init__ MonadPlus self value))

  (defn __lt__ [self other]
    "left should always be less than right"
    (cond
      (not (isinstance self #(Left Right)))
        (raise (TypeError "unorderable types:" (type self) (type other)))
      ;; same monad type, compare against the value inside
      (is (type self) (type other))
        (< self.value other.value)
      self False
      True True))

  (defn bind [self f]
    "the bind operation of :class:`Either`

    apply function to the value if and only if this is a :class:`Right`."
    (if self (f self.value) self))

  (defn plus [self other] (or self other))

  (defn [classmethod] from-value [cls value]
    "wrap :code:`value` in an :class:`Either` monad

    return a :class:`Right` if the value is evaluated as true.
    :class:`Left` otherwise."
    ((if value Right Left) value)))

(defclass Left [Either]
  "left of :class:`Either`"
  (defn __bool__ [self] False)
  (setv __nonzero__ __bool__)
  (defn plus [self other] other))

(defclass Right [Either]
  "right of :class:`Either`")

;; we are always right!
(setv Either.unit Right
      Either.zero (Left "unknown error"))

(defn left? [m]
  "return :code:`True` if :code:`m` is a :class:`Left`"
  (isinstance m Left))

(defn right? [m]
  "return :code:`True` if :code:`m` is a :class:`Right`"
  (isinstance m Right))

(defn either [handle-left handle-right m]
  "case analysis for :class:`Either`

  apply either :code:`handle-left` or :code:`handle-right` to :code:`m`
  depending on the type of it,  raise :code:`TypeError` if :code:`m` is not an
  :class:`Either`"
  (cond
    (left? m) (handle-left m.value)
    (right? m) (handle-right m.value)
    True (raise (TypeError "use either on non-Either type"))))

(defn failsafe [func]
  "decorator to turn func into monadic function of :class:`Either` monad"
  (defn [(wraps func)] wrapper [#* args #** kwargs]
    (try
      (Right (func #* args #** kwargs))
      (except [e BaseException]
        (Left e))))
  wrapper)

;; alias
(setv either-m Either
      ->either Either.from-value
      to-either ->either
      is-left left?
      is-right right?)

(export
  :objects [either-m Either
            ->either to-either
            Left Right
            left? right?
            is-left is-right
            either failsafe])
