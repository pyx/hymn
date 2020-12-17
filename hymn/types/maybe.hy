;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.
"hymn.types.maybe - the maybe monad"

(import
  [contextlib [suppress]]
  [functools [partial wraps]]
  [hymn.mixins [Ord]]
  [hymn.types.monadplus [MonadPlus]]
  [hymn.types.monoid [Monoid]])

(deftag ? [f]
  (with-gensyms [maybe]
    `(do (import [hymn.types.maybe [maybe :as ~maybe]]) (~maybe ~f))))

(defclass Maybe [MonadPlus Monoid Ord]
  "the maybe monad

  computation that may fail"
  (defn __init__ [self value]
    (when (is (type self) Maybe)
      (raise (NotImplementedError "please use Just instead")))
    (.__init__ (super Maybe self) value))

  (defn __lt__ [self other]
    (if
      (and (nothing? self) (nothing? other)) False
      (nothing? self) True
      (nothing? other) False
      (.__lt__ (super Maybe self) other)))

  (defn append [self other]
    "the append operation of :class:`Maybe`"
    (if
      (nothing? self) other
      (nothing? other) self
      ;; NOTE:
      ;; assuming both are of type Maybe here, also assuming the
      ;; underlying values are monoids with + as append.
      (Just (+ self.value other.value))))

  (defn bind [self f]
    "the bind operation of :class:`Maybe`

    apply function to the value if and only if this is a :class:`Just`."
    (if self (f self.value) Nothing))

  (defn plus [self other] (or self other))

  (defn from-maybe [self default]
    "return the value contained in the :class:`Maybe`

    if the :class:`Maybe` is :data:`Nothing`, it returns the default values."
    (if (nothing? self) default self.value))

  (with-decorator classmethod
    (defn from-value [cls value]
      "wrap :code:`value` in a :class:`Maybe` monad

      return a :class:`Just` if the value is evaluated as True.
      :data:`Nothing` otherwise."
      (if value (Just value) Nothing))))

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

;; alias
(setv maybe-m Maybe
      zero Maybe.zero
      from-maybe Maybe.from-maybe
      <-maybe from-maybe
      to-maybe Maybe.from-value
      ->maybe to-maybe)

(defn nothing? [m]
  "return :code:`True` if :code:`m` is :data:`Nothing`"
  (is m Nothing))

(defn maybe [&optional func predicate nothing-on-exceptions]
  "decorator to turn func into monadic function of the :class:`Maybe` monad"
  (if-not func
    (partial maybe
             :predicate predicate
             :nothing-on-exceptions nothing-on-exceptions)
    (do
      (setv exceptions (or nothing-on-exceptions [BaseException]))
      (with-decorator (wraps func)
        (fn [&rest args &kwargs kwargs]
          (setv result Nothing)
          (with [(suppress #* exceptions)]
            (setv result (Just (func #* args #** kwargs))))
          (when (and predicate (not (>> result predicate)))
            (setv result Nothing))
          result)))))
