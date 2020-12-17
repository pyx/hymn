# -*- coding: utf-8 -*-
# Copyright (c) 2014-2020, Philip Xu <pyx@xrefactor.com>
# License: BSD New, see LICENSE for details.
"""Hy Monad Notation - a monad library for Hy"""

__version__ = (0, 9)
__release__ = ''

VERSION = '%d.%d' % __version__ + __release__

try:
    # make .hy file importable
    import hy  # noqa
except ImportError:
    # ignore import error, need this for setup.py: import .version
    pass
