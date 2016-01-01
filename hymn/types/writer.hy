;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2016, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hymn.types.writer - the writer monad"

(import
  decimal
  fractions
  [hymn.types.monad [Monad]])

(defreader + [w]
  (with-gensyms [tell]
    `(do (import [hymn.types.writer [tell :as ~tell]]) (~tell ~w))))

(defclass Writer [Monad]
  "the writer monad

  computation which accumulate output along with result"
  [[bind (fn [self f]
           "the bind operation of :class:`Writer`"
           (let [[[v a] self.value]
                 [[nv na] (. (f v) value)]]
             ((type self) (, nv (+ a na)))))]
   [unit (with-decorator classmethod
           (fn [cls value]
             "the unit of writer monad"
             (cls (, value (cls.output-type)))))]
   [execute (fn [self]
              "extract the output of the writer"
              (second (.run self)))]
   [run (fn [self]
          "unwrap the writer computation"
          self.value)]])

(defn writer-with-type [t]
  "create a writer for type t"
  (type (+ (.title (. t --name--)) (str 'Writer)) (, Writer) {'output-type t}))

;;; Here, some predefined writers, it's not necessary because of the way we
;;; create writers with the above actions, just for convenience
(def ComplexWriter (writer-with-type complex))
(def DecimalWriter (writer-with-type decimal.Decimal))
(def FloatWriter (writer-with-type float))
(def FractionWriter (writer-with-type fractions.Fraction))
(def ListWriter (writer-with-type list))
(def IntWriter (writer-with-type int))
(def StringWriter (writer-with-type str))
(def TupleWriter (writer-with-type tuple))

;;; alias
(def writer-m Writer)
(def complex-writer-m ComplexWriter)
(def decimal-writer-m DecimalWriter)
(def float-writer-m FloatWriter)
(def fraction-writer-m FractionWriter)
(def list-writer-m ListWriter)
(def int-writer-m IntWriter)
(def string-writer-m StringWriter)
(def tuple-writer-m TupleWriter)
(def execute Writer.execute)
(def run Writer.run)

(defn writer-with-type-of [message]
  "create a writer of type of message"
  (writer-with-type (type message)))

(defn writer [value message]
  "embed a writer action with :code:`value` and :code:`message`"
  ((writer-with-type-of message) (, value message)))

(defn tell [message]
  "log the :code:`message`"
  ((writer-with-type-of message) (, nil message)))

(defn listen [m]
  "execute :code:`m` and adds its output to the value of computation"
  (def [v a] m.value)
  ((type m) (, m.value a)))

;;; NOTE:
;;; Hy/Python is dynamically-typed, this function might change the type of the
;;; output without notice.
(defn censor [f m]
  "apply :code:`f` to the output"
  (def [v a] m.value)
  ((type m) (, v (f a))))
