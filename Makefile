NAME = $(shell python setup.py --name)
FULLNAME = $(shell python setup.py --fullname)
DESCRIPTION = $(shell python setup.py --description)
VERSION = $(shell python setup.py --version)
URL = $(shell python setup.py --url)

DOCS_DIR = docs

.PHONY: clean help install docs doc-html doc-pdf dev-install quality release test tox

help:
	@echo '$(NAME) - $(DESCRIPTION)'
	@echo 'Version: $(VERSION)'
	@echo 'URL: $(URL)'
	@echo
	@echo 'Targets:'
	@echo '  help         : display this help text.'
	@echo '  install      : install package $(NAME).'
	@echo '  test         : run all tests.'
	@echo '  tox          : run all tests with tox.'
	@echo '  docs         : generate documentation files.'
	@echo '  quality      : code quality check.'
	@echo '  clean        : remove files created by other targets.'

install:
	pip install --upgrade .

dev-install:
	pip install --upgrade -e .[dev,doc,test]

docs: doc-html doc-pdf

doc-html: test
	cd $(DOCS_DIR); $(MAKE) html

doc-pdf: test
	cd $(DOCS_DIR); $(MAKE) latexpdf

release: clean quality tox
	@echo 'Checking release version, abort if attempt to release a dev version.'
	echo '$(VERSION)' | grep -qv dev
	@echo 'Bumping version number to $(VERSION), abort if no pending changes.'
	hg commit -m 'Bumped version number to $(VERSION)'
	@echo "Tagging release version $(VERSION), abort if already exists."
	hg tag $(VERSION)
	@echo "Creating packages."
	python setup.py sdist bdist_wheel
	@echo "Signing packages."
	gpg --detach-sign -a 'dist/$(FULLNAME).tar.gz'
	gpg --detach-sign -a 'dist/$(FULLNAME)-py2.py3-none-any.whl'
	@echo "Uploading to PyPI."
	twine upload dist/*
	@echo "Done."

test:
	py.test

tox:
	tox

quality:
	flake8 hymn tests

clean:
	cd $(DOCS_DIR) && $(MAKE) clean
	rm -rf build/ dist/ htmlcov/ *.egg-info MANIFEST $(DOCS_DIR)/conf.pyc *~
	rm -rf hymn/*.pyc hymn/__pycache__/
	rm -rf hymn/types/*.pyc hymn/types/__pycache__/
	rm -rf tests/*.pyc tests/__pycache__/
	rm -rf .tox/ .pytest_cache/
	rm -rf examples/*.pyc examples/__pycache__/
