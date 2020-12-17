;; -*- coding: utf-8 -*-
;; Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
;; License: BSD New, see LICENSE for details.

(import
  [hymn.types [identity :as identity-module]])

(defn test-module-level-unit []
  "identity module should have a working module level unit function"
  (assert (instance? identity-module.Identity (identity-module.unit None))))
