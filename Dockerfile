# build the cbioportal backend
FROM maven:3-eclipse-temurin-21 AS build_backend

# clone the cbioportal backend repo and checkout the version 6.0.4
RUN git clone https://github.com/cBioPortal/cbioportal.git
WORKDIR /cbioportal
RUN git checkout frontend-v6.0.4

# activate the standard logging configuration
RUN cp src/main/resources/logback.xml.EXAMPLE     src/main/resources/logback.xml

# copy the modified application configuration
COPY application.properties src/main/resources/application.properties

RUN mvn dependency:go-offline --fail-never

RUN mvn install package -DskipTests -q
RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*-exec.jar)


FROM maven:3-eclipse-temurin-21

# install dependencies / mysql
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    gnupg \
    gzip \
    lsb-release \
    mysql-server

# copy the mysql setup script and make it executable
RUN mkdir -p /scripts
COPY setup-mysql.sh /scripts/
RUN chmod +x /scripts/setup-mysql.sh

# copy over backend files
RUN mkdir -p /cbioportal
COPY --from=build_backend /cbioportal/target/*-exec.jar cbioportal/app.jar

# copy the modified application configuration
COPY application.properties cbioportal/application.properties

ENV PORTAL_HOME=/cbioportal
ENV PORTAL_WEB_HOME=/cbioportal


# download the database schema and seed data that works for the backend version 6.0.4
# (version 2.13.1, see https://github.com/cBioPortal/datahub/blob/master/seedDB/README.md)
RUN wget -O /scripts/cgds.sql "https://raw.githubusercontent.com/cBioPortal/cbioportal/a3794f7cd5a60974b8c04938d5b3d784a5bfb09a/db-scripts/src/main/resources/cgds.sql"
RUN wget -O /scripts/seed.sql.gz "https://raw.githubusercontent.com/cBioPortal/datahub/e2d892b2950caf0b30cfc2b1b2a9f3d89a7e7a33/seedDB/seed-cbioportal_hg19_hg38_v2.13.1.sql.gz"
RUN gunzip /scripts/seed.sql.gz

RUN service mysql start && scripts/setup-mysql.sh

# expose backend port
EXPOSE 8080

# run mysql, initialize the database, start the cbioportal backend
CMD ["bash", "-c", "service mysql start && cd /cbioportal &&  java -jar app.jar -Dauthenticate=false"]

