;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2017, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.

(import
  [hymn.operations [lift]])

(require
  [hymn.macros
    [^ =
     do-monad
     do-monad-m
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

(defn test-sharp-macro-^ [monad-runner]
  "lift sharp macro ^ should expand to lift call"
  (setv [monad run] monad-runner)
  (setv unit monad.unit)
  (assert (m= ((lift inc) (unit data)) (#^ inc (unit data)))))

(defn test-sharp-macro-= [monad-runner]
  "m-return sharp macro = should expand to m-return call"
  (setv [monad run] monad-runner)
  (setv unit monad.unit)
  (setv m-return unit)
  (assert (m= (unit data) #= data)))

(defn test-do-monad-return-monad [monad-runner]
  "do-monad macro should wrap result in monad automatically"
  (setv [monad run] monad-runner)
  (setv unit monad.unit)
  (assert (instance? monad (do-monad [a (unit data)] a))))

(defn test-do-monad [monad-runner]
  "do-monad macro should work"
  (setv [monad run] monad-runner)
  (setv unit monad.unit)
  (assert (m= (unit (inc data))
              (do-monad [a (unit data)] (inc a)))))

(defn test-do-monad-let-binding [monad-runner]
  "do-monad macro should support let binding"
  (setv [monad run] monad-runner)
  (setv unit monad.unit)
  (assert (m= (unit (inc data))
              (do-monad [a (unit data) :let [b (inc a)]] b))))

(defn test-do-monad-multiple-bindings [monad-runner]
  "do-monad macro should allow multiple bindings"
  (setv [monad run] monad-runner)
  (setv unit monad.unit)
  (setv m-inc (monad.monadic inc))
  (assert (m= (unit (inc data))
              (do-monad [a (unit data) b (m-inc a)] b))))

(defn test-do-monad-when [monadplus-runner]
  "do-monad macro should support when with monadplus"
  (setv [monadplus run] monadplus-runner)
  (setv unit monadplus.unit)
  (assert (m= (unit (inc data))
              (do-monad [a (unit data) :when (= a data)] (inc a))))
  (assert (m= monadplus.zero
              (do-monad [a (unit data) :when (!= a data)] (inc a)))))

(defn test-do-monad-m [monad-runner]
  "do-monad-m macro should work"
  (setv [monad run] monad-runner)
  (setv unit monad.unit)
  (assert (m= (unit (inc data))
              (do-monad-m [a (unit data)] (m-return (inc a))))))

(defn test-do-monad-with [monad-runner]
  "do-monad-with macro should provide a default m-return"
  (setv [monad run] monad-runner)
  (setv unit monad.unit)
  (assert (instance? monad (do-monad-with monad [a (m-return data)] a)))
  (assert (m= (unit (inc data))
              (do-monad-with monad [a (m-return data)] (inc a)))))

(defn test-monad-threading-macro [monad-runner]
  "monad-> macro should transform the form into do-monad-m macro"
  (setv [monad run] monad-runner)
  (setv m+ (monad.monadic +))
  (setv m/ (monad.monadic /))
  (setv m (monad.unit data))
  (assert (m= (do-monad-m [a m] (m/ a 2))
              (monad-> m (m/ 2))))
  (assert (m= (do-monad-m [a m b (m+ a 4) c (m+ b 8)] (m/ c 2))
              (monad-> m (m+ 4) (m+ 8) (m/ 2)))))

(defn test-monad-threading-macro-single-symbol [monad-runner]
  "monad-> macro should work with single symbol"
  (setv [monad run] monad-runner)
  (setv m-inc (monad.monadic inc))
  (setv m-half (monad.monadic (fn [n] (/ n 2))))
  (setv m (monad.unit data))
  (assert (m= (do-monad-m [a m] (m-half a))
              (monad-> m m-half)))
  (assert (m= (do-monad-m [a m b (m-inc a) c (m-inc b)] (m-half c))
              (monad-> m m-inc m-inc m-half))))

(defn test-monad-threading-tail-macro [monad-runner]
  "monad->> macro should transform the form into do-monad-m macro"
  (setv [monad run] monad-runner)
  (setv m+ (monad.monadic +))
  (setv m/ (monad.monadic /))
  (setv m (monad.unit data))
  (assert (m= (do-monad-m [a m] (m/ 2 a))
              (monad->> m (m/ 2))))
  (assert (m= (do-monad-m [a m b (m+ 4 a) c (m+ 8 b)] (m/ 2 c))
              (monad->> m (m+ 4) (m+ 8) (m/ 2)))))

(defn test-monad-threading-tail-macro-single-symbol [monad-runner]
  "monad->> macro should work with single symbol"
  (setv [monad run] monad-runner)
  (setv m-inc (monad.monadic inc))
  (setv m-invert (monad.monadic (fn [n] (/ 1 n))))
  (setv m (monad.unit data))
  (assert (m= (do-monad-m [a m] (m-invert a))
              (monad->> m m-invert)))
  (assert (m= (do-monad-m [a m b (m-inc a) c (m-inc b)] (m-invert c))
              (monad->> m m-inc m-inc m-invert))))

(defn test-m-for [monad-runner]
  "monadic for macro should work"
  (setv [monad run] monad-runner)
  (setv unit monad.unit)
  (assert (m= (unit (list (map inc (range 42))))
              (m-for [n (range 42)]
                (unit (inc n))))))

(defn test-m-when [monad-runner]
  "conditional execution with m-when"
  (setv [monad run] monad-runner)
  (setv unit monad.unit)
  (assert (m= (unit (inc data))
              (do-monad [a (unit data) b (m-when (= a data) #= (inc a))] b))))

(defn test-monad-comp [monad-runner]
  "monad comprehension macro should work as do monad in different syntax"
  (setv [monad run] monad-runner)
  (setv unit monad.unit)
  (assert (m= (monad-comp (inc data) [a (unit data)])
              (do-monad [a (unit data)] (inc a)))))

(defn test-monad-comp-condition [monadplus-runner]
  "monad comprehension macro should support :when with monadplus"
  (setv [monadplus run] monadplus-runner)
  (setv unit monadplus.unit)
  (assert (m= (monad-comp (inc data) [a (unit data)] (= a data))
              (do-monad [a (unit data) :when (= a data)] (inc a))))
  (assert (m= (monad-comp (inc data) [a (unit data)] (!= a data))
              (do-monad [a (unit data) :when (!= a data)] (inc a)))))

(defn test-with-monad [monad]
  "with-monad should provide default function m-return"
  (assert (instance? monad (with-monad monad (m-return None)))))
