;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

(import
  [hymn.operations [lift]])

(require
  [hymn.macros
    [^ =
     do-monad-return
     do-monad
     do-monad-with
     m-for
     m-when
     monad->
     monad->>
     monad-comp
     with-monad]])

(defmacro m= [m1 m2]
  `(= (run ~m1) (run ~m2)))

(setv data 42)

(defn test-tag-macro-^ [monad-runner]
  "lift tag macro ^ should expand to lift call"
  (setv [monad run] monad-runner
        unit monad.unit)
  (assert (m= ((lift inc) (unit data)) (#^ inc (unit data)))))

(defn test-tag-macro-= [monad-runner]
  "m-return tag macro = should expand to m-return call"
  (setv [monad run] monad-runner
        unit monad.unit
        m-return unit)
  (assert (m= (unit data) #= data)))

(defn test-do-monad-return-return-monad [monad-runner]
  "do-monad-return macro should wrap result in monad automatically"
  (setv [monad run] monad-runner
        unit monad.unit)
  (assert (instance? monad (do-monad-return [a (unit data)] a))))

(defn test-do-monad-return [monad-runner]
  "do-monad-return macro should work"
  (setv [monad run] monad-runner
        unit monad.unit)
  (assert (m= (unit (inc data))
              (do-monad-return [a (unit data)] (inc a)))))

(defn test-do-monad-return-let-binding [monad-runner]
  "do-monad-return macro should support let binding"
  (setv [monad run] monad-runner
        unit monad.unit)
  (assert (m= (unit (inc data))
              (do-monad-return [a (unit data) :let [b (inc a)]] b))))

(defn test-do-monadultiple-bindings [monad-runner]
  "do-monad-return macro should allow multiple bindings"
  (setv [monad run] monad-runner
        unit monad.unit
        m-inc (monad.monadic inc))
  (assert (m= (unit (inc data))
              (do-monad-return [a (unit data) b (m-inc a)] b))))

(defn test-do-monad-when [monadplus-runner]
  "do-monad-return macro should support when with monadplus"
  (setv [monadplus run] monadplus-runner
        unit monadplus.unit)
  (assert (m= (unit (inc data))
              (do-monad-return [a (unit data) :when (= a data)] (inc a))))
  (assert (m= monadplus.zero
              (do-monad-return [a (unit data) :when (!= a data)] (inc a)))))

(defn test-do-monad [monad-runner]
  "do-monad macro should work"
  (setv [monad run] monad-runner
        unit monad.unit)
  (assert (m= (unit (inc data))
              (do-monad [a (unit data)] (m-return (inc a))))))

(defn test-do-monad-with [monad-runner]
  "do-monad-with macro should provide a default m-return"
  (setv [monad run] monad-runner
        unit monad.unit)
  (assert (instance? monad (do-monad-with monad [a (m-return data)] a)))
  (assert (m= (unit (inc data))
              (do-monad-with monad [a (m-return data)] (inc a)))))

(defn test-monad-threading-macro [monad-runner]
  "monad-> macro should transform the form into do-monad macro"
  (setv [monad run] monad-runner
        m+ (monad.monadic +)
        m/ (monad.monadic /)
        m (monad.unit data))
  (assert (m= (do-monad [a m] (m/ a 2))
              (monad-> m (m/ 2))))
  (assert (m= (do-monad [a m b (m+ a 4) c (m+ b 8)] (m/ c 2))
              (monad-> m (m+ 4) (m+ 8) (m/ 2)))))

(defn test-monad-threading-macro-single-symbol [monad-runner]
  "monad-> macro should work with single symbol"
  (setv [monad run] monad-runner
        m-inc (monad.monadic inc)
        m-half (monad.monadic (fn [n] (/ n 2)))
        m (monad.unit data))
  (assert (m= (do-monad [a m] (m-half a))
              (monad-> m m-half)))
  (assert (m= (do-monad [a m b (m-inc a) c (m-inc b)] (m-half c))
              (monad-> m m-inc m-inc m-half))))

(defn test-monad-threading-tail-macro [monad-runner]
  "monad->> macro should transform the form into do-monad macro"
  (setv [monad run] monad-runner
        m+ (monad.monadic +)
        m/ (monad.monadic /)
        m (monad.unit data))
  (assert (m= (do-monad [a m] (m/ 2 a))
              (monad->> m (m/ 2))))
  (assert (m= (do-monad [a m b (m+ 4 a) c (m+ 8 b)] (m/ 2 c))
              (monad->> m (m+ 4) (m+ 8) (m/ 2)))))

(defn test-monad-threading-tail-macro-single-symbol [monad-runner]
  "monad->> macro should work with single symbol"
  (setv [monad run] monad-runner
        m-inc (monad.monadic inc)
        m-invert (monad.monadic (fn [n] (/ 1 n)))
        m (monad.unit data))
  (assert (m= (do-monad [a m] (m-invert a))
              (monad->> m m-invert)))
  (assert (m= (do-monad [a m b (m-inc a) c (m-inc b)] (m-invert c))
              (monad->> m m-inc m-inc m-invert))))

(defn test-m-for [monad-runner]
  "monadic for macro should work"
  (setv [monad run] monad-runner
        unit monad.unit)
  (assert (m= (unit (list (map inc (range 42))))
              (m-for [n (range 42)]
                (unit (inc n))))))

(defn test-m-when [monad-runner]
  "conditional execution with m-when"
  (setv [monad run] monad-runner
        unit monad.unit)
  (assert (m= (unit (inc data))
              (do-monad-return
                [a (unit data) b (m-when (= a data) #= (inc a))]
                b))))

(defn test-monad-comp [monad-runner]
  "monad comprehension macro should work as do monad in different syntax"
  (setv [monad run] monad-runner
        unit monad.unit)
  (assert (m= (monad-comp (inc data) [a (unit data)])
              (do-monad-return [a (unit data)] (inc a)))))

(defn test-monad-comp-condition [monadplus-runner]
  "monad comprehension macro should support :when with monadplus"
  (setv [monadplus run] monadplus-runner
        unit monadplus.unit)
  (assert (m= (monad-comp (inc data) [a (unit data)] (= a data))
              (do-monad-return [a (unit data) :when (= a data)] (inc a))))
  (assert (m= (monad-comp (inc data) [a (unit data)] (!= a data))
              (do-monad-return [a (unit data) :when (!= a data)] (inc a)))))

(defn test-with-monad [monad]
  "with-monad should provide default function m-return"
  (assert (instance? monad (with-monad monad (m-return None)))))
