#!/bin/bash
. $(dirname $0)/config

mv /etc/solr/conf/schema.xml /etc/solr/conf/schema.xml.bak
ln -s $CKAN_VENV/src/ckan/ckan/config/solr/schema-1.4.xml /etc/solr/conf/schema.xml

perl -pi -e '
s/^.*NO_START.+$/NO_START=0/;
s/^.*JETTY_HOST.+$/JETTY_HOST=127.0.0.1/;
s/^.*JETTY_PORT=.+$/JETTY_PORT=8983/;
s,^.*JAVA_HOME=.+,JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64/,;' /etc/default/jetty

/etc/init.d/jetty start
