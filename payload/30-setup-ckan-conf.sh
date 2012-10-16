#!/bin/bash
. $(dirname $0)/config

cd $CKAN_ROOT

$CKAN_VENV/bin/paster make-config ckan $CKAN_CFG

ln -s $CKAN_VENV/src/ckan/who.ini
mkdir data sstore
chown www-data . data sstore

# Config hostname
perl -pi -e "s/^ckan.site_url.*$/ckan.site_url = $CKAN_HOSTNAME/" $CKAN_CFG
