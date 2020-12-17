# -*- coding: utf-8 -*-
import sys
from os import path
from setuptools import setup

if sys.version_info < (3, 6):
    sys.exit('hymn requires Python 3.6 or higher')

ROOT_DIR = path.abspath(path.dirname(__file__))
sys.path.insert(0, ROOT_DIR)

from hymn import VERSION
from hymn import __doc__ as DESCRIPTION
LONG_DESCRIPTION = open(path.join(ROOT_DIR, 'README.rst')).read()


HYSRC = ['**.hy']


setup(
    name='hymn',
    version=VERSION,
    description=DESCRIPTION,
    long_description=LONG_DESCRIPTION,
    url='https://github.com/pyx/hymn/',
    author='Philip Xu',
    author_email='pyx@xrefactor.com',
    license='BSD-New',
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: BSD License',
        'Operating System :: OS Independent',
        "Programming Language :: Lisp",
        "Programming Language :: Python",
        "Programming Language :: Python :: 3",
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
        'Topic :: Software Development :: Libraries :: Python Modules',
    ],
    keywords='hy lisp monad functional programming',
    install_requires=[
        'hy>=0.19.0',
    ],
    extras_require={
        'dev': [
            'twine',
        ],
        'doc': [
            'Sphinx',
        ],
        'test': [
            'flake8',
            'pytest',
            'tox',
        ],
    },
    packages=['hymn', 'hymn.types'],
    package_data={'hymn': HYSRC, 'hymn.types': HYSRC},
    zip_safe=False,
    platforms='any',
)
