;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2017, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hymn.types.maybe - the maybe monad"

(import
  [functools [partial wraps]]
  [hymn.mixins [Ord]]
  [hymn.types.monadplus [MonadPlus]]
  [hymn.types.monoid [Monoid]]
  [hymn.utils [suppress]])

(defreader ? [f]
  (with-gensyms [maybe]
    `(do (import [hymn.types.maybe [maybe :as ~maybe]]) (~maybe ~f))))

(defclass Maybe [MonadPlus Monoid Ord]
  "the maybe monad

  computation that may fail"
  (defn --init-- [self value]
    (when (is (type self) Maybe)
      (raise (NotImplementedError "please use Just instead")))
    (.--init-- (super Maybe self) value))

  (defn --lt-- [self other]
    (if
      (and (nothing? self) (nothing? other)) False
      (nothing? self) True
      (nothing? other) False
      (.--lt-- (super Maybe self) other)))

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
(def Maybe.unit Just)
(def unit Maybe.unit)

(defclass Nothing [Maybe]
  "the :class:`Maybe` that represents nothing, a singleton, like :code:`None`"
  (defn --bool-- [self] False)
  (def --nonzero-- --bool--)
  (defn --repr-- [self] "Nothing")
  (defn bind [self f] Nothing)
  (defn plus [self other] other))

;;; shadow the class intensionally
(def Nothing (Nothing (object)))
(def Maybe.zero Nothing)
(def Maybe.empty Nothing)

;;; alias
(def maybe-m Maybe)
(def zero Maybe.zero)
(def from-maybe Maybe.from-maybe)
(def <-maybe from-maybe)
(def to-maybe Maybe.from-value)
(def ->maybe to-maybe)

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
      (def exceptions (or nothing-on-exceptions [BaseException]))
      (with-decorator (wraps func)
        (fn [&rest args &kwargs kwargs]
          (def result Nothing)
          (with [(apply suppress exceptions)]
            (setv result (Just (apply func args kwargs))))
          (when (and predicate (not (>> result predicate)))
            (setv result Nothing))
          result)))))
