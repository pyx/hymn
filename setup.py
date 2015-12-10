# -*- coding: utf-8 -*-
import sys
from os import path
from distutils.core import setup

if sys.version_info < (2, 7):
    sys.exit('hymn requires Python 2.7 or higher')

ROOT_DIR = path.abspath(path.dirname(__file__))
sys.path.insert(0, ROOT_DIR)

from hymn import VERSION
from hymn import __doc__ as DESCRIPTION
LONG_DESCRIPTION = open(path.join(ROOT_DIR, 'README.rst')).read()

DEP = [
    'hy>=0.11.0',
]

EXTRA_DEP = {
    'dev': [
        'twine',
    ],
    'doc': [
        'Sphinx>=1.2.3',
    ],
    'test': [
        'pytest>=2.6.4',
    ],
}

HYSRC = ['**.hy']

setup(
    name='hymn',
    version=VERSION,
    description=DESCRIPTION,
    long_description=LONG_DESCRIPTION,
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: BSD License',
        'Operating System :: OS Independent',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3.3',
        'Programming Language :: Python :: 3.4',
        'Topic :: Software Development :: Libraries :: Python Modules',
    ],
    author='Philip Xu',
    author_email='pyx@xrefactor.com',
    url='https://github.com/pyx/hymn/',
    download_url=(
        'https://bitbucket.org/pyx/hymn/get/%s.tar.bz2' % VERSION),
    install_requires=DEP,
    extras_require=EXTRA_DEP,
    packages=['hymn', 'hymn.types'],
    package_data={'hymn': HYSRC, 'hymn.types': HYSRC},
    license='BSD-New',
)
