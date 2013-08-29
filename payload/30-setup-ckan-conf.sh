#!/bin/bash
. $(dirname $0)/config

cd $CKAN_ROOT

$CKAN_VENV/bin/paster make-config ckan $CKAN_CFG

# we need to touch/chown the logfile so we do it
# before any paster command creates it as root
touch ckan.log
chown www-data . ckan.log

# data is the pylons cache
# sstore is for openid connections
mkdir data sstore
chown www-data data sstore
ln -s $CKAN_VENV/src/ckan/who.ini

# Config hostname
perl -pi -e "s,^ckan.site_url.*$,ckan.site_url = http://$CKAN_HOSTNAME/," $CKAN_CFG

# should we use s3-storage?
if [ ! -z "$CKAN_STORAGE_BUCKET" ] ; then
	perl -pi -e 's/^.*ofs.impl = s3.*$/ofs.impl = s3/' $CKAN_CFG
	# in e0cd7ba46e260b503b4090d1a382c5bc5dcf7db8 the stanza in the template disappeared
	#perl -pi -e "s/^.*ckan.storage.bucket.*$/ckan.storage.bucket = $CKAN_STORAGE_BUCKET/" $CKAN_CFG
	perl -pi -e 's/^.*ofs.impl = s3.*$/ofs.impl = s3/' $CKAN_CFG
	perl -pi -e "s/s3$/s3\nckan.storage.bucket = $CKAN_STORAGE_BUCKET/" $CKAN_CFG
fi
