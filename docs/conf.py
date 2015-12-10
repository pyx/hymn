# -*- coding: utf-8 -*-
#
# Hymn documentation build configuration file
import os
import sys

PROJECT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '../'))
sys.path.insert(0, PROJECT_DIR)
import hymn

extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.coverage',
    'sphinx.ext.viewcode',
]

source_suffix = '.rst'

master_doc = 'index'

project = u'Hymn'
copyright = u'2014-2015, Philip Xu'
author = u'Philip Xu'

version = '%d.%d' % hymn.__version__
release = hymn.VERSION

language = None

exclude_patterns = ['_build']

pygments_style = 'colorful'

todo_include_todos = False

html_theme = 'bizstyle'
# use RTD new theme
RTD_NEW_THEME = True

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
   author, 'Hymn', hymn.__doc__,
   'Miscellaneous'),
]
