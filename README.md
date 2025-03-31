# cBioPortal Docker Image
This Image is based on cBioPortal (https://github.com/cBioPortal/cbioportal).
It hosts the cBioPortal Backend, Frontend and a MySQL Database in a single Docker Container.
The Database gets set up with the cBioPortal schema and seed data (https://github.com/cBioPortal/datahub/tree/master/seedDB),
as well as common genesets (https://github.com/cBioPortal/datahub/tree/master/reference_data/gene_panels).
You can import your own data into cBioPortal by providing a directory with the studies you want to import.
It also hosts a loading page that redirects you to the application once its finished importing.


# Building and Running the cBioPortal Docker Container
## 1. Build the Docker Image:
### ```docker build -t cbioportal .```
This can take a long time to complete, as it will download and build all the dependencies required to run the cBioPortal application.


## 2. Prepare the import directory:
To import data into cBioPortal you need to provide a directory with the following two subdirectories (gene_panels is optional):
- studies (you should put all study directories that you want to import here)
- gene_panels (incase your studies need special gene panels, you can put them here directly to import them)

The importTest directory provided in this repo contains a few working sample studies downloaded from the official cBioPortal website.
## 3. Run the Docker Container:
### ```docker run -v /path/to/import/volume:/import -p 80:80 cbioportal```
This will start the cBioPortal application and import all studies/genesets from the mounted /import directory.
## 4. Open the application:
### http://localhost:80
You will first be greeted with a loading screen, as the application is still importing the data / starting up.
Once the import is complete, you will be redirected to the cBioPortal homepage.

# Using it in your Galaxy instance
## 1. Copy the tool
Copy "interactivetool_cbioportal.xml" into galaxy/tools/interactive
## 2. Update tool config
Update your tool config under galaxy/config/tool_conf.xml to include cbioportal under the Interactive Tool section like this:
```
<section id="interactivetools" name="Interactive Tools">
    <tool file="interactive/interactivetool_cbioportal.xml" />
</section>
```