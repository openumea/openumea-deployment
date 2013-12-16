#!/bin/bash
. $(dirname $0)/config

virtualenv $CKAN_VENV
# Grab the release tag from github
$CKAN_VENV/bin/pip install --ignore-installed -e git+git://github.com/okfn/ckan.git@ckan-2.1.1#egg=ckan
# install its dependencies
$CKAN_VENV/bin/pip install --ignore-installed -r $CKAN_VENV/src/ckan/requirements.txt
# install a good version of boto.
$CKAN_VENV/bin/pip install boto==2.20.1

# OPTIONAL things we don't currently use
#$CKAN_VENV/bin/pip install celery

# Example on how to install plugins
#$CKAN_VENV/bin/pip install -e git+git://github.com/okfn/ckanext-datastorer.git#egg=ckanext-datastorer
#$CKAN_VENV/bin/pip install -r $CKAN_VENV/src/ckanext-datastorer/pip-requirements.txt
