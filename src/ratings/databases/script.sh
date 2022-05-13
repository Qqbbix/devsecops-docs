#!/bin/sh

set -e
mongoimport --host localhost --username $MONGODB_EXTRA_USERNAMES --password $MONGODB_EXTRA_PASSWORDS \
  --db $MONGODB_EXTRA_DATABASES --collection ratings --drop --file /docker-entrypoint-initdb.d/ratings_data.json