#!/bin/bash
. $(dirname $0)/config

# Should we restore db from backup?
if [ ! -z "$CKAN_BACKUP" ] ; then
	# download backup?
	if [ ! -e "$CKAN_BACKUP" ] ; then
		CKAN_BACKUP_DOWNLOADED=$(basename $CKAN_BACKUP)
		$CKAN_VENV/bin/fetch_file --out-file=$CKAN_BACKUP_DOWNLOADED $CKAN_BACKUP
		CKAN_BACKUP=$CKAN_BACKUP_DOWNLOADED
	fi
	# uncompress
	if [[ "$CKAN_BACKUP" = *".gz" ]] ; then
		gunzip $CKAN_BACKUP
		CKAN_BACKUP=$(echo $CKAN_BACKUP | sed -ie 's/\.gz$//')
	fi
	# load db dump
	$CKAN_VENV/bin/paster --plugin=ckan db load --file=$CKAN_BACKUP --config=$CKAN_CFG
	# And upgrade any changes
	$CKAN_VENV/bin/paster --plugin=ckan db upgrade --config=$CKAN_CFG
else
	# init a fesh db
	$CKAN_VENV/bin/paster --plugin=ckan db init --config=$CKAN_CFG
	$CKAN_VENV/bin/paster --plugin=ckan user add $CKAN_SYSADMIN_USER password="$CKAN_SYSADMIN_PW" --config=$CKAN_CFG
	$CKAN_VENV/bin/paster --plugin=ckan sysadmin add $CKAN_SYSADMIN_USER --config=$CKAN_CFG
fi
