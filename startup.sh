#!/bin/bash
set -e

# start MySQL service
service mysql start

# wait for database to start
echo "Waiting for MySQL to start..."
while ! mysqladmin ping -hlocalhost --silent; do
    sleep 1
done

echo "MySQL started"

# start cBioPortal
cd /cbioportal
java -jar app.jar -Dauthenticate=false &

# wait for cBioPortal to be ready
while ! curl -s http://localhost:8080/api/health | grep '\"status\":\"UP\"' > /dev/null; do
    echo 'Waiting for cBioPortal to be ready for Import...'
    sleep 5
done

#/venv/bin/python ../core/scripts/migrate_db.py -y -p /cbioportal/application.properties -s /cbioportal/db-scripts/migration.sql

# run the metaImport script
/venv/bin/python ../core/scripts/importer/metaImport.py -s /data/study_es_0 -u http://localhost:8080 -html myReport.html -o -v -r
/bin/bash