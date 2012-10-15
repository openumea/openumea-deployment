#!/bin/bash
. $(dirname $0)/config

cd $CKAN_ROOT

PW=$(pwgen 12 1)
sudo -u postgres psql -c "CREATE ROLE ckan PASSWORD '$PW' NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN;"
sudo -u postgres psql -c "CREATE DATABASE ckan OWNER ckan;"

perl -pi -e "s,^sqlalchemy.url=.*,sqlalchemy.url=postgresql://ckan:$PW@localhost/ckan?sslmode=disable,"  $CKAN_CFG
