#!/bin/bash
. $(dirname $0)/config

cd $CKAN_ROOT

CKAN_DB_USER=ckan
CKAN_DB_PW=$(pwgen 12 1)
CKAN_DB=ckan
CKAN_DB_HOST=localhost
sudo -u postgres psql -c "CREATE ROLE ${CKAN_DB_USER} PASSWORD '${CKAN_DB_PW}' NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN;"
sudo -u postgres psql -c "CREATE DATABASE ${CKAN_DB} OWNER ${CKAN_DB_USER} TEMPLATE template0 ENCODING 'UTF8';"

perl -pi -e "s,^sqlalchemy.url.*,sqlalchemy.url=postgresql://${CKAN_DB_USER}:${CKAN_DB_PW}\@${CKAN_DB_HOST}/${CKAN_DB}?sslmode=disable," $CKAN_CFG

# Should we prepare for datastore?
if [ ! "$DATASTORE" = "1" ] ; then
	exit 0;
fi

CKAN_DATASTORE_USER=datastore
CKAN_DATASTORE_PW=$(pwgen 12 1)
CKAN_DATASTORE_DB=datastore
CKAN_DATASTORE_HOST=localhost
sudo -u postgres psql -c "CREATE DATABASE ${CKAN_DATASTORE_DB} OWNER ${CKAN_DB_USER} TEMPLATE template0 ENCODING 'UTF8';"
sudo -u postgres psql -c "CREATE ROLE ${CKAN_DATASTORE_USER} PASSWORD '${CKAN_DATASTORE_PW}' NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN;"

perl -pi -e "s,^#ckan.datastore.write_url.*,ckan.datastore.write_url=postgresql://${CKAN_DB_USER}:${CKAN_DB_PW}\@${CKAN_DATASTORE_HOST}/${CKAN_DATASTORE_DB}?sslmode=disable," $CKAN_CFG
perl -pi -e "s,^#ckan.datastore.read_url.*,ckan.datastore.read_url=postgresql://${CKAN_DATASTORE_USER}:${CKAN_DATASTORE_PW}\@${CKAN_DATASTORE_HOST}/${CKAN_DATASTORE_DB}?sslmode=disable," $CKAN_CFG

# Let ckan setup the correct permissions on the different dbs for the different users.
$CKAN_VENV/bin/paster --plugin=ckan datastore set-permissions postgres --config=$CKAN_CFG
