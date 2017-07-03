Changelog
=========

- 0.7

  - Backward incompatible change supporting hy 0.13
  - Renamed sharp macro * to ~
  - Removed macros in hymn.dsl, use hymn.macros instead

- 0.6

  - Backward incompatible change supporting hy 0.12, using new syntax
  - Moved monad operation macros into separate module: hymn.macros

- 0.5

  - Version bump to indicate at least halfway done with planned features

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
