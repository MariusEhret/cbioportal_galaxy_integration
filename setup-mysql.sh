#!/bin/bash
set -e

# database details
MYSQL_ROOT_PASSWORD=root_password
MYSQL_DATABASE1=cbioportal
MYSQL_DATABASE2=cgds_test
MYSQL_USER=cbio
MYSQL_PASSWORD=P@ssword1

# add the local_infile setting to my.cnf because it is required for the importer
echo "Adding local_infile setting to /etc/mysql/my.cnf"
echo "[mysqld]" >> /etc/mysql/my.cnf
echo "local_infile=1" >> /etc/mysql/my.cnf

# wait for database to start
echo "Waiting for MySQL to start..."
while ! mysqladmin ping -hlocalhost --silent; do
    sleep 1
done

echo "MySQL started"

# check if the database has already been initialized
if [ -f /var/lib/mysql/.initialized ]; then
    echo "Database already initialized."
    exit 0
fi

echo "Initializing database, this will take a while..."

# initialize the database
mysql -u root <<-EOSQL
    ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY '${MYSQL_ROOT_PASSWORD}';
    CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE1};
    CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE2};

    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL ON ${MYSQL_DATABASE1}.* TO '${MYSQL_USER}'@'localhost';
    GRANT ALL ON ${MYSQL_DATABASE2}.* TO '${MYSQL_USER}'@'localhost';

    FLUSH PRIVILEGES;
EOSQL

# import the database schema
mysql --user=cbio --password=P@ssword1 cbioportal < /scripts/cgds.sql

# import the seed data
mysql --user=cbio --password=P@ssword1 cbioportal < /scripts/seed.sql
#mysql --user=cbio_user --password=somepassword cbioportal < seed-cbioportal_hg19_vX.Y.Z_only-pdb.sql

echo "Database initialized"

# mark the script as completed
touch /var/lib/mysql/.initialized