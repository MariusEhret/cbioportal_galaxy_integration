#!/bin/bash
set -e

# start MySQL service
service mysql start

# start cBioPortal
cd /cbioportal
java -jar app.jar -Dauthenticate=false &

# wait for cBioPortal to be ready
while ! curl -s http://localhost:8080/api/health | grep '\"status\":\"UP\"' > /dev/null; do
    echo 'Waiting for cBioPortal to be ready for Import...'
    sleep 5
done

# run the metaImport script
/venv/bin/python ../core/scripts/importer/metaImport.py -s /data/study_es_0 -u http://localhost:8080 -html myReport.html -o -v -r