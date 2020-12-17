;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.
"hymn.types.monadplus - base monadplus class"

(import
  [hymn.types.monad [Monad]])

(defclass MonadPlus [Monad]
  "the monadplus class

  Monads that also support choice and failure."
  (defn __add__ [self other] (self.plus other))

  (defn plus [self other]
    "the associative operation"
    (raise NotImplementedError))

  (with-decorator property
    (defn zero [self]
      "the identity of :meth:`plus`.

      It should satisfy the following law, left zero
      (notice the bind operator is haskell's :code:`>>=` here)::

       zero >>= f = zero"
      (raise NotImplementedError))))
