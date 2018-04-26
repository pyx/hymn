# -*- coding: utf-8 -*-
import sys
from os import path
from setuptools import setup

if sys.version_info < (2, 7):
    sys.exit('hymn requires Python 2.7 or higher')

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
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Topic :: Software Development :: Libraries :: Python Modules',
    ],
    keywords='hy lisp monad functional programming',
    download_url=(
        'https://bitbucket.org/pyx/hymn/get/%s.tar.bz2' % VERSION),
    install_requires=[
        'hy>=0.14.0',
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
