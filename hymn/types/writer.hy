;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2018, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hymn.types.writer - the writer monad"

(import
  decimal
  fractions
  [hymn.types.monad [Monad]])

(deftag + [w]
  (with-gensyms [tell]
    `(do (import [hymn.types.writer [tell :as ~tell]]) (~tell ~w))))

(defclass Writer [Monad]
  "the writer monad

  computation which accumulate output along with result"
  (defn bind [self f]
    "the bind operation of :class:`Writer`"
    (setv
      [v a] self.value
      [nv na] (. (f v) value))
    ((type self) (, nv (+ a na))))

  (with-decorator classmethod
    (defn unit [cls value]
      "the unit of writer monad"
      (cls (, value (cls.output-type)))))

  (defn execute [self] "extract the output of writer" (second (.run self)))

  (defn run [self] "unwrap the writer computation" self.value))

(defn writer-with-type [t]
  "create a writer for type t"
  (type (+ (.title (. t --name--)) (str 'Writer)) (, Writer) {'output_type t}))

;;; Here, some predefined writers, it's not necessary because of the way we
;;; create writers with the above actions, just for convenience
(setv ComplexWriter (writer-with-type complex))
(setv DecimalWriter (writer-with-type decimal.Decimal))
(setv FloatWriter (writer-with-type float))
(setv FractionWriter (writer-with-type fractions.Fraction))
(setv ListWriter (writer-with-type list))
(setv IntWriter (writer-with-type int))
(setv StringWriter (writer-with-type str))
(setv TupleWriter (writer-with-type tuple))

;;; alias
(setv writer-m Writer)
(setv complex-writer-m ComplexWriter)
(setv decimal-writer-m DecimalWriter)
(setv float-writer-m FloatWriter)
(setv fraction-writer-m FractionWriter)
(setv list-writer-m ListWriter)
(setv int-writer-m IntWriter)
(setv string-writer-m StringWriter)
(setv tuple-writer-m TupleWriter)
(setv execute Writer.execute)
(setv run Writer.run)

(defn writer-with-type-of [message]
  "create a writer of type of message"
  (writer-with-type (type message)))

(defn writer [value message]
  "embed a writer action with :code:`value` and :code:`message`"
  ((writer-with-type-of message) (, value message)))

(defn tell [message]
  "log the :code:`message`"
  ((writer-with-type-of message) (, None message)))

(defn listen [m]
  "execute :code:`m` and adds its output to the value of computation"
  (setv [v a] m.value)
  ((type m) (, m.value a)))

;;; NOTE:
;;; Hy/Python is dynamically-typed, this function might change the type of the
;;; output without notice.
(defn censor [f m]
  "apply :code:`f` to the output"
  (setv [v a] m.value)
  ((type m) (, v (f a))))
