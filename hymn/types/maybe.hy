;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2023, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.
"hymn.types.maybe - the maybe monad"

(import
  contextlib [suppress]
  functools [partial wraps]
  ..mixins [Ord]
  .monadplus [MonadPlus]
  .monoid [Monoid])

(defreader ? (setv f (.parse-one-form &reader))
  `(hy.I.hymn.types.maybe.maybe ~f))

(defclass Maybe [MonadPlus Monoid Ord]
  "the maybe monad

  computation that may fail"
  (defn __init__ [self value]
    (when (is (type self) Maybe)
      (raise (NotImplementedError "please use Just instead")))
    (.__init__ (super Maybe self) value))

  (defn __lt__ [self other]
    (cond
      (and (nothing? self) (nothing? other)) False
      (nothing? self) True
      (nothing? other) False
      True (.__lt__ (super Maybe self) other)))

  (defn append [self other]
    "the append operation of :class:`Maybe`"
    (cond
      (nothing? self) other
      (nothing? other) self
      ;; NOTE:
      ;; assuming both are of type Maybe here, also assuming the
      ;; underlying values are monoids with + as append.
      True (Just (+ self.value other.value))))

  (defn bind [self f]
    "the bind operation of :class:`Maybe`

    apply function to the value if and only if this is a :class:`Just`."
    (if self (f self.value) Nothing))

  (defn plus [self other] (or self other))

  (defn from-maybe [self default]
    "return the value contained in the :class:`Maybe`

    if the :class:`Maybe` is :data:`Nothing`, it returns the default values."
    (if (nothing? self) default self.value))

  (defn [classmethod] from-value [cls value]
    "wrap :code:`value` in a :class:`Maybe` monad

    return a :class:`Just` if the value is evaluated as True.
    :data:`Nothing` otherwise."
    (if value (Just value) Nothing)))

(defclass Just [Maybe] ":code:`Just` of the :class:`Maybe`")
(setv Maybe.unit Just
      unit Maybe.unit)

(defclass Nothing [Maybe]
  "the :class:`Maybe` that represents nothing, a singleton, like :code:`None`"
  (defn __bool__ [self] False)
  (setv __nonzero__ __bool__)
  (defn __repr__ [self] "Nothing")
  (defn bind [self f] Nothing)
  (defn plus [self other] other))

;; shadow the class intensionally
(setv Nothing (Nothing (object))
      Maybe.zero Nothing
      Maybe.empty Nothing)

(defn nothing? [m]
  "return :code:`True` if :code:`m` is :data:`Nothing`"
  (is m Nothing))

(defn maybe [[func None] [predicate None] [nothing-on-exceptions None]]
  "decorator to turn func into monadic function of the :class:`Maybe` monad"
  (if (not func)
    (partial maybe
             :predicate predicate
             :nothing-on-exceptions nothing-on-exceptions)
    (do
      (setv exceptions (or nothing-on-exceptions [BaseException]))
      (defn [(wraps func)] wrapper [#* args #** kwargs]
        (setv result Nothing)
        (with [(suppress #* exceptions)]
          (setv result (Just (func #* args #** kwargs))))
        (when (and predicate (not (>> result predicate)))
          (setv result Nothing))
        result)
      wrapper)))

;; alias
(setv maybe-m Maybe
      from-maybe Maybe.from-maybe
      <-maybe from-maybe
      to-maybe Maybe.from-value
      ->maybe to-maybe
      is_nothing nothing?)

(export
  :objects [maybe-m Maybe
            <-maybe from-maybe
            ->maybe to-maybe
            Just Nothing
            nothing? maybe is_nothing])
