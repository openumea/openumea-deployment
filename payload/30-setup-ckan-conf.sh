#!/bin/bash
. $(dirname $0)/config

cd $CKAN_ROOT

$CKAN_VENV/bin/paster make-config ckan $CKAN_CFG

ln -s $CKAN_VENV/src/ckan/who.ini
mkdir data sstore
touch ckan.log
chown www-data . data sstore ckan.log

# Config hostname
perl -pi -e "s,^ckan.site_url.*$,ckan.site_url = http://$CKAN_HOSTNAME/," $CKAN_CFG

# XXX: Hardcoded "theme"
perl -pi -e 's/^ckan.site_title.*$/ckan.site_title = Openumea CKAN Site/' $CKAN_CFG
perl -pi -e 's,^ckan.site_logo.*$,ckan.site_logo = http://www.umea.se/images/18.73d525c912cecb285058000245/umea-kommun-vit-logo.gif,' $CKAN_CFG

# should we use s3-storage?
if [ ! -z "$CKAN_STORAGE_BUCKET" ] ; then
	perl -pi -e 's/^.*ofs.impl = s3.*$/ofs.impl = s3/' $CKAN_CFG
	perl -pi -e "s/^.*ckan.storage.bucket.*$/ckan.storage.bucket = $CKAN_STORAGE_BUCKET/" $CKAN_CFG
fi
