# -*- coding: utf-8 -*-
# Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
# License: BSD New, see LICENSE for details.
from pytest import Module

from hymn.types.monadplus import MonadPlus
from hymn.types.monoid import Monoid

from hymn.types.continuation import Continuation
from hymn.types.either import Either
from hymn.types.identity import Identity
from hymn.types.lazy import Lazy
from hymn.types.list import List
from hymn.types.maybe import Maybe
from hymn.types.reader import Reader
from hymn.types.state import State
from hymn.types.writer import (
    ComplexWriter,
    DecimalWriter,
    FloatWriter,
    FractionWriter,
    ListWriter,
    IntWriter,
    StringWriter,
    TupleWriter,
)


def pytest_collect_file(path, parent):
    if path.ext == ".hy" and path.basename.startswith('test_'):
        return Module.from_parent(parent, fspath=path)


def extract(m):
    return m >> (lambda v: v)


def run_cont(c):
    return c.run()


def run_lazy(m):
    return m.evaluate()


def run_list(lst):
    return list(lst)


def run_reader(r):
    return r.run(None)


def run_state(s):
    return s.run(None)


def run_writer(w):
    return w.run()[0]


monad_runners = [
    (Continuation, run_cont),
    (Either, extract),
    (Identity, extract),
    (Lazy, run_lazy),
    (List, run_list),
    (Maybe, extract),
    (Reader, run_reader),
    (State, run_state),
    (ComplexWriter, run_writer),
    (DecimalWriter, run_writer),
    (FloatWriter, run_writer),
    (FractionWriter, run_writer),
    (ListWriter, run_writer),
    (IntWriter, run_writer),
    (StringWriter, run_writer),
    (TupleWriter, run_writer),
]

monads = [monad for (monad, runner) in monad_runners]
monad_ids = [monad.__name__ for monad in monads]

monadplus_runners = [
    (monad, runner)
    for (monad, runner) in monad_runners
    if issubclass(monad, MonadPlus)
]

monadplus = [monadplus for (monadplus, runner) in monadplus_runners]
monadplus_ids = [monad.__name__ for monad in monadplus]

monoid_runners = [
    (monad, runner)
    for (monad, runner) in monad_runners
    if issubclass(monad, Monoid)
]

monoids = [monoid for (monoid, runner) in monoid_runners]
monoid_ids = [monoid.__name__ for monoid in monoids]

params = [
    ('monad', monads, monad_ids),
    ('monad_runner', monad_runners, monad_ids),
    ('monadplus', monadplus, monadplus_ids),
    ('monadplus_runner', monadplus_runners, monadplus_ids),
    ('monoid', monoids, monoid_ids),
    ('monoid_runner', monoid_runners, monoid_ids),
]


def pytest_generate_tests(metafunc):
    for name, args, ids in params:
        if name in metafunc.fixturenames:
            metafunc.parametrize(name, args, ids=ids)
