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

cd ../core/scripts

# import all gene panels given in the /import/genePanels directory
echo "Starting import for gene panels..."
if [ -d /import/gene_panels ]; then
  for gene_panel in /import/gene_panels/*; do
    echo "Importing gene panel: $gene_panel"
    perl importGenePanel.pl --data "$gene_panel"
  done
  echo "Gene panel import complete."
else
  echo "No gene panels found, skipping panel import. If this is not intended, please add gene panels to the mounted directory 'import' under  'import/gene_panels'"
fi

# iterate over /import/studies and run the metaImport script for every directory
echo "Starting import for studies..."
if [ -d /import/studies ]; then
  for study_dir in /import/studies/*; do
    if [ -d "$study_dir" ]; then
      echo "Importing study: $study_dir"
      /venv/bin/python importer/metaImport.py -s "$study_dir" -u http://localhost:8080 -html metaImportReport.html -o -v -r
    fi
  done
  echo "Study import complete."
else
  echo "No studies found, skipping study import. If this is not intended, please add studies to the mounted directory 'import' under 'import/studies'"
fi


# create a file to indicate the completion of the metaImport script
touch /var/run/meta_import_complete

/bin/bash