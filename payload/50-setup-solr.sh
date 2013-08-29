#!/bin/bash
. $(dirname $0)/config

mv /etc/solr/conf/schema.xml /etc/solr/conf/schema.xml.bak
ln -s $CKAN_VENV/src/ckan/ckan/config/solr/schema-2.0.xml /etc/solr/conf/schema.xml

perl -pi -e '
s/^.*NO_START.+$/NO_START=0/;
s/^.*JETTY_HOST.+$/JETTY_HOST=127.0.0.1/;
s/^.*JETTY_PORT=.+$/JETTY_PORT=8983/;' /etc/default/jetty

cat >> /etc/default/jetty <<EOS

# define which java to use
JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64/
EOS

/etc/init.d/jetty start

perl -pi -e 's,^.*solr_url.*$,solr_url = http://127.0.0.1:8983/solr,' $CKAN_CFG
