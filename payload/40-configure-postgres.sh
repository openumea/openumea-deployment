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
