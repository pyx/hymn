# -*- coding: utf-8 -*-
# Copyright (c) 2014-2015, Philip Xu <pyx@xrefactor.com>
# License: BSD New, see LICENSE for details.

from hymn.types.continuation import Continuation
from hymn.types.either import Either
from hymn.types.identity import Identity
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


def extract(m):
    return m >> (lambda v: v)


def run_cont(c):
    return c.run()


def run_list(l):
    return list(l)


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
    if hasattr(monad, 'plus')
]

monadplus = [monadplus for (monadplus, runner) in monadplus_runners]
monadplus_ids = [monad.__name__ for monad in monadplus]


def pytest_generate_tests(metafunc):
    if 'monad' in metafunc.funcargnames:
        metafunc.parametrize('monad', monads, ids=monad_ids)
    if 'monad_runner' in metafunc.funcargnames:
        metafunc.parametrize('monad_runner', monad_runners, ids=monad_ids)
    if 'monadplus' in metafunc.funcargnames:
        metafunc.parametrize('monadplus', monadplus, ids=monadplus_ids)
    if 'monadplus_runner' in metafunc.funcargnames:
        metafunc.parametrize(
            'monadplus_runner', monadplus_runners, ids=monadplus_ids)
