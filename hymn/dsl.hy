;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.
"hymn.dsl - dsl for computation with monads"

;; expose some types and actions here for easier import

(import
  .types.monoid [<> append]
  .types.continuation [Continuation cont-m continuation-m call-cc call/cc]
  .types.either [Either either-m
                 Left Right left? right? is-left is-right either failsafe]
  .types.identity [Identity identity-m]
  .types.lazy [Lazy lazy-m force lazy? is_lazy]
  .types.list [List fmap list-m]
  .types.maybe [Maybe maybe-m
                <-maybe from-maybe
                ->maybe to-maybe
                Just Nothing
                nothing? maybe is_nothing]
  .types.reader [Reader reader-m
                 reader
                 <- :as <-r
                 ask ask :as get-env
                 asks asks :as get-env-with
                 local local :as use-env-with
                 lookup :as lookup-reader]
  .types.state [State state-m
                <-state get-state set-state state<-
                <- :as <-s
                gets gets :as get-state-with
                lookup :as lookup-state
                modify modify :as modify-state-with
                set-value set-value :as set-state-value
                set-values set-values :as set-state-values
                update update :as update-state-value-with
                update-value update-value :as update-state-value]
  .types.writer [ComplexWriter complex-writer-m
                 DecimalWriter decimal-writer-m
                 FloatWriter float-writer-m
                 FractionWriter fraction-writer-m
                 ListWriter list-writer-m
                 IntWriter int-writer-m
                 StringWriter string-writer-m
                 TupleWriter tuple-writer-m
                 censor listen tell writer
                 writer-with-type
                 writer-with-type-of]
  .operations [k-compose <=< k-pipe >=> lift m-map replicate sequence])

(require
  hymn.macros * :readers [^ =]
  hymn.types.continuation :readers [<]
  hymn.types.either :readers [|]
  hymn.types.lazy [lazy]
  hymn.types.list :readers [@]
  hymn.types.maybe :readers [?])
