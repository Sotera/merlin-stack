# merlin-stack

# Stack Pre-requisites
  * The stack in it's current form requires a Hypervisor (Vsphere, Virtualbox, AWS EC2, Openstack)
  * The stack also requires persistent network attached storage.  Specifically NFS mountable storage (QNAP, NFS Server,
   AWS Elastic Storage)
  * Depending on the Hypervisor used you may need to use a specific os image (provided) for the base docker host
  * Docker repository containing all Docker images the stack requires (provided)

# Stack Contents
* ### Services
  * Web Services
    * Hadoop Web UI
      * location : [any node ip]:8088
      * Lists all spark jobs running or otherwise as well as ETL logs and spark cluster status
    * HDFS Web UI
      * location : [any node ip]:50070
      * Lists Hadoop File System nodes and status.  Also allows for file browsing within HDFS
    * PostgreSQL Admin page
      * location : [any node ip]:5050
      * Allows for administration of the PostgreSQL database
    * Merlin ETL Dashboard
      * location : [any node ip]:3000
      * Management of Datasets, Users and Roles
      * Dataset ETL Kickoff and status updates      
    * Merlin Data API Explorer
      * location : [any node ip]:3000/explorer
      * Allows programatic access to all data in the system
    * Elasticsearch Head
      * location : [any node ip]:9100
      * Web UI for management of the Elastic Cluster
    * Kibana
      * location : [any node ip]:5601
      * Web UI for analysis of Elasticsearch Data
    * Traefik Web Proxy
      * location : [any node ip]:8080
    * Newman Email Analytics
      * location : [any node ip]:5000
      * Email analytics user interface
    * Jupyter
      * location : [any node ip]:9999
      * Python development environment when wanting to work with data directly using python
      
  * Data Storage
    *PostgreSQL
      * location : Inside the stack at postgres:5432, Direct connections are not available outside the stack
    *Elasticsearch
      * location : Inside the stack at elasticsearch:9200
  
  * Other
    * SFTP server for file transfer
            * location : [any node ip]:2201  
    
  # Building the Docker Images
    
  # Installation:
  ### Build Machine running on the target hypervisor
    * Build Server
      *It is recommended that you start up a linux build vm on the target hypervisor.  From the build machine you will
      deploy the host machines and all services that form the Merlin Stack.  The build machine must have access to the 
      Docker repository
    * Install Docker version <docker version here>
    * Parrot Repo
      * The Parrot repo and Merlin repo need to be next to eachother in the directory structure because there are 
      sym-links from the Merlin stack to the Parrot stack.
      * Clone the Parrot repo
      * The Parrot repo is the base stack for the Merlin stack.  All images in the Merlin stack are built from images
      build in the Parrot repo.
    * Merlin Repo
      * Clone the Merlin repo next to the Parrot repo.
      * Edit or create a new deployment json file. <Link to json editing instructions>
      * 
    * Firmament install
      * NodeJs install
      * sudo npm install firmament
      * firmament module i --name docker
      * firmament module i --name docker-machine
      * If you do not have access to the internet you will need to install Firmament on a computer connected to the
      internet and package it up to be moved to the target system.  Once you have installed Firmament you can use it
      to make a packaged version of itself by running "firmament package tar".  This will create a tar.gz file containing
      the entirety of the firmament application with all dependencies.
    * 
  ### Firmament
    * Firmament is an application we developed to read json files and deploy our services based on the settings within.
    * 
  ### Ensure NFS mounts are available and match the Firmament File
    * "hadoop-datavolume": /merlin-lts\
      "hadoop-logvolume": /merlin-lts-logs\
      "postgres": /merlin-lts/db/postgresql\
      "elasticsearch0": /merlin-lts/db/es1\
      "elasticsearch1": /merlin-lts/db/es2\
      "elasticsearch2": /merlin-lts/db/es3\
      "uploads": /merlin-lts/uploads\
      "nifi-datavolume": /nifi/data\
      
    * Directory structure
      * The directory structure should all be chowned to 907:907
      * The required directory structure for the NFS mount is as follows:
        * Base merlin mount folder (typically "merlin-lts")
          * db
            * es1
            * es2
            * es3
            * postgresql
          * merlin-etl
            * data
            * share\
              _The share folder contains everything required for the ETL system to run.  All configuration files, jar 
              files, dependencies and scripts are required in a specific structure.  This folder has been provided and
              should be copied into the merlin-etl folder on the nfs mount prior to any stack deployment._
          * notebooks
          * uploads
        * Base merlin log mount folder (typically "merlin-lts-logs")
        * Base nifi transfer area (typically "nifi")
          * data\
            _The data folder holds all files post ETL that are filtered for NiFi_
    * location of all config files and job definitions
      
  # Positioning Data
  
  ### Creation of Datasets
  * You may create datasets either by using the dataset creation user interface located on the stack management page or
  you can create them via our data api.  To see the api and use the data api explorer go to [any node ip]:3000
 
  ### Manual data positioning
  * To manually position data for ingest you place the data in a folder in the /[nfs mount]/merlin/merlin-etl/data directory
  * Once you have data positioned you use the data API explorer to add the relative path to the file array property of
   the dataset.  Relative pathing should follow the following format /mnt/merlin/merlin-etl/data/[your file or folder].
   All containers have the NFS directory mounted at /mnt/merlin/... and any data placed in these folders will be shared
   by all containers.  
  * Typically this method of data positioning is reserved for very large datasets.  Smaller datasets should be uploaded
  via the dataset upload page, see below.
  
  ### Data Upload
  * An easier method of adding data to a dataset is to simply upload the data using the dataset creation page.  Expand
  the dataset row of your choice and use the interface to upload a file.  Once uploaded the dataset will be ready for 
  ingest.
  
  # ETL Execution
  ### Manual ETL Execution
  ### Automatic ETL Execution
