Changelog
=========

- 0.4

  - Support python 3.5
  - Remove alias of compose and pipe <| and |> to avoid confusion
  - New macros: monad-> and monad->>, threading macros for monad

- 0.3

  - New operation: m-map
  - New macros: m-for, monad-comp
  - New type: deferred computation implemented as the Lazy monad
  - Improved documentation

- 0.2

  - List.unit now support any number of initial values
  - Maybe and List are instances of Monoid

- 0.1

  First public release.
