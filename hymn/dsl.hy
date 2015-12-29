;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2014-2015, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hymn.dsl - dsl for computation with monads"

;;; expose some types and actions here for easier import

(import
  [hymn.types.monoid [<> append]]
  [hymn.types.continuation
    [Continuation cont-m continuation-m
     call-cc
     run :as run-cont]]
  [hymn.types.either
    [Either either-m
     Left Right left? right? either failsafe]]
  [hymn.types.lazy [Lazy lazy-m evaluate :as evaluate-lazy force lazy?]]
  [hymn.types.list [List fmap list-m]]
  [hymn.types.maybe
    [Maybe maybe-m
     Just Nothing <-maybe ->maybe from-maybe maybe nothing? to-maybe]]
  [hymn.types.reader
    [Reader reader-m
     reader
     <- :as <-r
     ask ask :as get-env
     asks asks :as get-env-with
     local local :as use-env-with
     lookup :as lookup-reader
     run :as run-reader]]
  [hymn.types.state
    [State state-m
     <-state get-state set-state state<-
     <- :as <-s
     evaluate :as evaluate-state
     execute :as execute-state
     gets gets :as get-state-with
     lookup :as lookup-state
     modify modify :as modify-state-with
     run :as run-state
     set-value set-value :as set-state-value
     set-values set-values :as set-state-values
     update update :as update-state-value-with
     update-value update-value :as update-state-value]]
  [hymn.types.writer
    [ComplexWriter complex-writer-m
     DecimalWriter decimal-writer-m
     FloatWriter float-writer-m
     FractionWriter fraction-writer-m
     ListWriter list-writer-m
     IntWriter int-writer-m
     StringWriter string-writer-m
     TupleWriter tuple-writer-m
     censor listen tell writer
     writer-with-type
     writer-with-type-of
     run :as run-writer
     execute :as execute-writer]]
  [hymn.operations
    [k-compose <=< k-pipe >=> lift m-map replicate sequence]]
  [hymn.utils [compose <| const pipe |>]])

;;; reader macro for the continuation monad
(require hymn.types.continuation)

;;; reader macro for the either monad
(require hymn.types.either)

;;; macros for the lazy monad
(require hymn.types.lazy)

;;; reader macro for the list monad
(require hymn.types.list)

;;; reader macro for the maybe monad
(require hymn.types.maybe)

;;; reader macro for the writer monad
(require hymn.types.writer)

;;; macros for monad operations
(require hymn.operations)
