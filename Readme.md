# Building and Running the cBioPortal Docker Container

## 1. Build the Docker Image:


### ```docker build -t cbioportal .```
 This can take a long time to complete, as it will download and build all the dependencies required to run the cBioPortal application.
## 2. Run the Docker Container:


### ```docker run -p 8080:8080 cbioportal```
On first startup this will take a while to complete, because it needs to set up the database
## 3. Open the application:


### http://localhost:8080