#!/bin/bash
. $(dirname $0)/config

if [ "$ENABLE_CKAN_RDF_TO_HTML" != "1" ]; then
  exit
fi

# This row needs to be added to the SOLR schema in order for the DCAT fields
# to be handled properly
perl -pi -e 's,^</fields>$,    <dynamicField name= "dcat_fields*" type="text" indexed="true" stored="true" multiValued="true"/>\n</fields>,' /etc/solr/conf/schema.xml

# Install the extension
$CKAN_VENV/bin/pip install -e git+git://github.com/openumea/ckanext-rdf-to-html.git#egg=ckanext-rdf-to-html

# Activate it
perl -pi -e 's,^(ckan.plugins.*)$,$1 rdf_to_html,' $CKAN_CFG

# Install the CKAN uploader

$CKAN_VENV/bin/pip install rdf-to-html

# Create a cronjob that runs it once a day

TMP=$(mktemp)
crontab -u www-data -l > $TMP
cat >> $TMP <<EOC
20  5  *   *   *     $CKAN_VENV/bin/ckan-uploader localhost $CKAN_API_KEY "$RDF_URL"
EOC
crontab -u www-data $TMP
rm $TMP
