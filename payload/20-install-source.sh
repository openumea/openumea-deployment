#!/bin/bash
. $(dirname $0)/config

virtualenv $CKAN_VENV
#$CKAN_VENV/bin/pip install --ignore-installed -e git+https://github.com/okfn/ckan.git#egg=ckan
$CKAN_VENV/bin/pip install --ignore-installed -e git+https://github.com/okfn/ckan.git@release-v1.8#egg=ckan
$CKAN_VENV/bin/pip install --ignore-installed -r $CKAN_VENV/src/ckan/pip-requirements.txt
#$CKAN_VENV/bin/pip install boto 
$CKAN_VENV/bin/pip install git+https://github.com/boto/boto#egg=boto

# OPTIONAL
$VENV/bin/pip install Celery
$VENV/bin/pip install -e git+git://github.com/okfn/ckanext-datastorer.git#egg=ckanext-datastorer
$VENV/bin/pip install -r $VENV/src/ckanext-datastorer/pip-requirements.txt
