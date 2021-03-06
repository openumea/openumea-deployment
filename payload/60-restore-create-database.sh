#!/bin/bash
. $(dirname $0)/config

# "dirty down" the right place
cd $CKAN_ROOT

# Should we restore db from backup?
if [ ! -z "$CKAN_BACKUP" ] ; then
	# download backup?
	if [ ! -e "$CKAN_BACKUP" ] ; then
		CKAN_BACKUP_DOWNLOADED=$CLOUD_DATA/$(basename $CKAN_BACKUP)
		$CKAN_VENV/bin/fetch_file --out-file=$CKAN_BACKUP_DOWNLOADED $CKAN_BACKUP
		CKAN_BACKUP=$CKAN_BACKUP_DOWNLOADED
	fi
	# uncompress
	if [[ "$CKAN_BACKUP" = *".gz" ]] ; then
		gunzip $CKAN_BACKUP
		CKAN_BACKUP=$(echo $CKAN_BACKUP | sed -e 's/\.gz$//')
	fi
	# load db dump
	$CKAN_VENV/bin/paster --plugin=ckan db load $CKAN_BACKUP --config=$CKAN_CFG
	# And upgrade any changes
	$CKAN_VENV/bin/paster --plugin=ckan db upgrade --config=$CKAN_CFG
	# And re-index everything
	$CKAN_VENV/bin/paster --plugin=ckan search-index rebuild -r --config=$CKAN_CFG
else
	# init a fesh db
	$CKAN_VENV/bin/paster --plugin=ckan db init --config=$CKAN_CFG
	$CKAN_VENV/bin/paster --plugin=ckan user add $CKAN_SYSADMIN_USER password="$CKAN_SYSADMIN_PW" email="$RECIPENT_EMAIL_ADDRESS" --config=$CKAN_CFG
	$CKAN_VENV/bin/paster --plugin=ckan sysadmin add $CKAN_SYSADMIN_USER --config=$CKAN_CFG
fi

if [ "$DATASTORE" = "1" ] && [ ! -z "$DATASTORE_BACKUP" ] ; then
	# download backup?
	if [ ! -e "$DATASTORE_BACKUP" ] ; then
		DATASTORE_BACKUP_DOWNLOADED=$CLOUD_DATA/$(basename $DATASTORE_BACKUP)
		$CKAN_VENV/bin/fetch_file --out-file=$DATASTORE_BACKUP_DOWNLOADED $DATASTORE_BACKUP
		DATASTORE_BACKUP=$DATASTORE_BACKUP_DOWNLOADED
	fi
	# uncompress
	if [[ "$DATASTORE_BACKUP" = *".gz" ]] ; then
		gunzip $DATASTORE_BACKUP
		DATASTORE_BACKUP=$(echo $DATASTORE_BACKUP | sed -e 's/\.gz$//')
	fi
	# load db dump
	sudo -u postgres psql datastore -f $DATASTORE_BACKUP
fi
