# -*- coding: utf-8 -*-
#
# Hymn documentation build configuration file
import pathlib
import sys
sys.path.insert(0, pathlib.Path(__file__).parents[2].resolve().as_posix())

extensions = [
    'sphinx.ext.doctest',
    'sphinx.ext.viewcode',
]

source_suffix = '.rst'

master_doc = 'index'

project = u'Hymn'
copyright = u'2014-2023, Philip Xu'
author = u'Philip Xu'

release = "1.0.0"

exclude_patterns = ['_build']

pygments_style = 'colorful'

html_theme = 'bizstyle'

htmlhelp_basename = 'Hymndoc'

latex_documents = [
  (master_doc, 'Hymn.tex', u'Hymn Documentation',
   u'Philip Xu', 'manual'),
]

man_pages = [
    (master_doc, 'hymn', u'Hymn Documentation',
     [author], 1)
]

texinfo_documents = [
  (master_doc, 'Hymn', u'Hymn Documentation',
   author, 'Hymn', "Hy Monad Notation - a monad library for Hy",
   'Miscellaneous'),
]
