Changelog
=========

- 0.9

  - Backward incompatible change supporting hy 0.19
  - Support python 3.7, 3.8, 3.9
  - Drop python 2.7, 3.4, 3.5 support
  - Renamed macro do-monad as do-monad-return
  - Renamed macro do-monad-m as do-monad

- 0.8

  - Backward incompatible change supporting hy 0.14
  - Drop python 3.3 support
  - Remove type-specific sharp macros in `hymn.macros`, newer hy does not
    support aggregating macros in a module.  Type-specific sharp macros are
    still available in their respective type modules.

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
  - Remove alias of compose and pipe <| and \|> to avoid confusion
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
