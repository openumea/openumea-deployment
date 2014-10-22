#!/bin/sh

# install all our prereqs
apt-get install -y python-dev postgresql libpq-dev python-pip python-virtualenv git-core solr-jetty openjdk-6-jdk
# and for a prod webserver
apt-get install -y apache2 apache2-utils libapache2-mod-wsgi
