;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2016, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.

(import
  [hymn.operations [lift]])

(require hymn.operations)

(defmacro m= [m1 m2]
  `(= (run ~m1) (run ~m2)))

(def data 42)

(defn test-reader-macro-^ [monad-runner]
  "life reader macro ^ should expand to lift call"
  (def [monad run] monad-runner)
  (def unit monad.unit)
  (assert (m= ((lift inc) (unit data)) (#^inc (unit data)))))

(defn test-reader-macro-= [monad-runner]
  "m-return reader macro = should expand to m-return call"
  (def [monad run] monad-runner)
  (def unit monad.unit)
  (def m-return unit)
  (assert (m= (unit data) #=data)))

(defn test-do-monad-return-monad [monad-runner]
  "do-monad macro should wrap result in monad automatically"
  (def [monad run] monad-runner)
  (def unit monad.unit)
  (assert (instance? monad (do-monad [a (unit data)] a))))

(defn test-do-monad [monad-runner]
  "do-monad macro should work"
  (def [monad run] monad-runner)
  (def unit monad.unit)
  (assert (m= (unit (inc data))
              (do-monad [a (unit data)] (inc a)))))

(defn test-do-monad-let-binding [monad-runner]
  "do-monad macro should support let binding"
  (def [monad run] monad-runner)
  (def unit monad.unit)
  (assert (m= (unit (inc data))
              (do-monad [a (unit data) :let [[b (inc a)]]] b))))

(defn test-do-monad-multiple-bindings [monad-runner]
  "do-monad macro should allow multiple bindings"
  (def [monad run] monad-runner)
  (def unit monad.unit)
  (def m-inc (monad.monadic inc))
  (assert (m= (unit (inc data))
              (do-monad [a (unit data) b (m-inc a)] b))))

(defn test-do-monad-when [monadplus-runner]
  "do-monad macro should support when with monadplus"
  (def [monadplus run] monadplus-runner)
  (def unit monadplus.unit)
  (assert (m= (unit (inc data))
              (do-monad [a (unit data) :when (= a data)] (inc a))))
  (assert (m= monadplus.zero
              (do-monad [a (unit data) :when (!= a data)] (inc a)))))

(defn test-do-monad-m [monad-runner]
  "do-monad-m macro should work"
  (def [monad run] monad-runner)
  (def unit monad.unit)
  (assert (m= (unit (inc data))
              (do-monad-m [a (unit data)] (m-return (inc a))))))

(defn test-do-monad-with [monad-runner]
  "do-monad-with macro should provide a default m-return"
  (def [monad run] monad-runner)
  (def unit monad.unit)
  (assert (instance? monad (do-monad-with monad [a (m-return data)] a)))
  (assert (m= (unit (inc data))
              (do-monad-with monad [a (m-return data)] (inc a)))))

(defn test-m-for [monad-runner]
  "monadic for macro should work"
  (def [monad run] monad-runner)
  (def unit monad.unit)
  (assert (m= (unit (list (map inc (range 42))))
              (m-for [n (range 42)]
                (unit (inc n))))))

(defn test-m-when [monad-runner]
  "conditional execution with m-when"
  (def [monad run] monad-runner)
  (def unit monad.unit)
  (assert (m= (unit (inc data))
              (do-monad [a (unit data) b (m-when (= a data) #=(inc a))] b))))

(defn test-monad-comp [monad-runner]
  "monad comprehension macro should work as do monad in different syntax"
  (def [monad run] monad-runner)
  (def unit monad.unit)
  (assert (m= (monad-comp (inc data) [a (unit data)])
              (do-monad [a (unit data)] (inc a)))))

(defn test-monad-comp-condition [monadplus-runner]
  "monad comprehension macro should support :when with monadplus"
  (def [monadplus run] monadplus-runner)
  (def unit monadplus.unit)
  (assert (m= (monad-comp (inc data) [a (unit data)] (= a data))
              (do-monad [a (unit data) :when (= a data)] (inc a))))
  (assert (m= (monad-comp (inc data) [a (unit data)] (!= a data))
              (do-monad [a (unit data) :when (!= a data)] (inc a)))))

(defn test-with-monad [monad]
  "with-monad should provide default function m-return"
  (assert (instance? monad (with-monad monad (m-return nil)))))
