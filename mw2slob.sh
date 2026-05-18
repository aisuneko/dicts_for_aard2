#!/bin/bash

# assume sudo for all the following
apt update && apt install python3 python3-icu python3-venv git curl apt-transport-https gnupg python3-lxml
python3 -m venv env-slob --system-site-packages
source env-slob/bin/activate
pip install git+https://github.com/itkach/slob.git
pip install https://github.com/itkach/mwscrape/tarball/master
pip install git+https://github.com/itkach/mw2slob.git
curl https://couchdb.apache.org/repo/keys.asc | gpg --dearmor | tee /usr/share/keyrings/couchdb-archive-keyring.gpg >/dev/null 2>&1
source /etc/os-release && echo "deb [signed-by=/usr/share/keyrings/couchdb-archive-keyring.gpg] https://apache.jfrog.io/artifactory/couchdb-deb/ ${VERSION_CODENAME} main" | tee /etc/apt/sources.list.d/couchdb.list >/dev/null
apt update && apt install couchdb
COUCHDB_USER=admin COUCHDB_PASSWORD=password /opt/couchdb/bin/couchdb &

# the site we are fetching
SITE="wiki.archlinux.org"
# mediawiki site api path
SITE_PATH="/"

SITE_NAME=$(sed 's/\./-/g' <<< $SITE)
mwscrape -c http://admin:password@localhost:5984 $SITE --site-path=$SITE_PATH
mw2slob scrape http://admin:password@127.0.0.1:5984/$SITE_NAME --ensure-ext-image-urls

# file is at ./$SITE_NAME.slob
