#!/bin/sh

# install all our prereqs
#mercurial 
apt-get install -y python-dev postgresql libpq-dev
apt-get install -y libxml2-dev libxslt-dev python-virtualenv
apt-get install -y wget build-essential git-core subversion
apt-get install -y solr-jetty openjdk-6-jdk
apt-get install -y libapache2-mod-wsgi
