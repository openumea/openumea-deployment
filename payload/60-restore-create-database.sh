#!/bin/bash
. $(dirname $0)/config

# Should we restore db from backup?
if [ ! -z "$CKAN_BACKUP" ] ; then
	# XXX: download backup?
	$CKAN_VENV/bin/paster --plugin=ckan db load --file=$CKAN_BACKUP --config=$CKAN_CONFIG
else
	# init a fesh db
	$CKAN_VENV/bin/paster --plugin=ckan db init --config=$CKAN_CONFIG
	$CKAN_VENV/bin/paster --plugin=ckan user add $CKAN_SYSADMIN_USER password="$CKAN_SYSADMIN_PW" --config=$CKAN_CONFIG
	$CKAN_VENV/bin/paster --plugin=ckan sysadmin add $CKAN_SYSADMIN_USER --config=$CKAN_CONFIG
fi
