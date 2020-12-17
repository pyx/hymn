;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.
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
  (type f"{(.title (name t))}Writer" (, Writer) {'output_type t}))

;; Here, some predefined writers, it's not necessary because of the way we
;; create writers with the above actions, just for convenience
(setv ComplexWriter (writer-with-type complex)
      DecimalWriter (writer-with-type decimal.Decimal)
      FloatWriter (writer-with-type float)
      FractionWriter (writer-with-type fractions.Fraction)
      ListWriter (writer-with-type list)
      IntWriter (writer-with-type int)
      StringWriter (writer-with-type str)
      TupleWriter (writer-with-type tuple))

;; alias
(setv writer-m Writer
      complex-writer-m ComplexWriter
      decimal-writer-m DecimalWriter
      float-writer-m FloatWriter
      fraction-writer-m FractionWriter
      list-writer-m ListWriter
      int-writer-m IntWriter
      string-writer-m StringWriter
      tuple-writer-m TupleWriter
      execute Writer.execute
      run Writer.run)

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

;; NOTE:
;; Hy/Python is dynamically-typed, this function might change the type of the
;; output without notice.
(defn censor [f m]
  "apply :code:`f` to the output"
  (setv [v a] m.value)
  ((type m) (, v (f a))))
