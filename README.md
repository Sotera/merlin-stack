# merlin-stack

# Stack Pre-requisites
* The stack in its current form requires a Hypervisor (Vsphere, Virtualbox, AWS EC2, Openstack)
* The stack also requires persistent network attached storage.  Specifically NFS mountable storage (QNAP, NFS Server,
AWS Elastic Storage)
* Depending on the Hypervisor used you may need to use a specific os image (provided) for the base docker host
    * AWS and Openstack will need the provided cloud-init image
    * Virtualbox and Vsphere will need the provided boot2docker image 
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
      * Web UI allowing access to all data in the system
    * Elasticsearch Head
      * location : [any node ip]:9100
      * Web UI for management of the Elastic Cluster
    * Kibana
      * location : [any node ip]:5601
      * Web UI for analysis of Elasticsearch Data
    * Traefik Web Proxy
      * location : [any node ip]:8080
      * Web UI displaying frontend/backend proxy routes for stack
    * Newman Email Analytics
      * location : [any node ip]:5000
      * Web UI to query and display email analytics
    * Jupyter
      * location : [any node ip]:9999
      * Python development environment for writing "on the fly" spark jobs against extracted data
      
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
      * It is recommended that you start up a linux build vm on the target hypervisor.  From the build machine you will
      deploy the host machines and all services that form the Merlin Stack.  The build machine must have access to the 
      Docker repository
    * Install Docker version 18.03
    * Parrot Repo
      * The Parrot repo and Merlin repo need to be next to each other in the directory structure because there are 
      sym-links from the Merlin stack to the Parrot stack.
      * Clone the Parrot repo
      * The Parrot repo is the base stack for the Merlin stack.  All images in the Merlin stack are built from images
      build in the Parrot repo.
    * Merlin Repo
      * Clone the Merlin repo next to the Parrot repo.
      * Edit or create a new deployment json file. <Link to json editing instructions>
    * Firmament install
      * NodeJs install
      * sudo npm install -g firmament
      * firmament module i --name docker
      * If you do not have access to the internet you will need to install Firmament on a computer connected to the
      internet and package it up to be moved to the target system.  Once you have installed Firmament you can use it
      to make a packaged version of itself by running "firmament package tar".  This will create a tar.gz file containing
      the entirety of the firmament application with all dependencies.
  
  ### Ensure NFS mounts are available and match the Firmament File
    * "hadoop-datavolume": /merlin-lts\
      "hadoop-logvolume": /merlin-lts-logs\
      "postgres": /merlin-lts/db/postgresql\
      "elasticsearch0": /merlin-lts/db/es1\
      "elasticsearch1": /merlin-lts/db/es2\
      "elasticsearch2": /merlin-lts/db/es3\
      "uploads": /merlin-lts/uploads\
      "nifi-datavolume": /nifi/data
      
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
  
  ### Firmament Stack Deployment
    * Deploying a stack requires that you be on a machine that is able to connect to the hypervisor, we suggest that it
    be a build machine VM running on the hypervisor so other team members are able to manage the stack from that VM.
    Once you have Firmament installed, a clone of the parrot-stack repo and a clone of the merlin-stack repo available
    you may continue with stack deployment.    
    * Firmament is an application we've developed to read json files and deploy our services based on the settings within.
    * Firmament deployment files are located in the Merlin repo under /firmament/deploy
      * Each hypervisor currently supported will have a directory under which we place all deployment files
      * Supported hypervisors include AWS, Openstack, VMWare, and Virtualbox
      * The json deployment files are labeled with the build version of the stack docker images
      * Changes to the Firmament deploy files can be made depending on environment, hardware and desired stack size/
      capability
    * To deploy a stack based on a firmament configuration file, navigate to the config file of your choice under the 
    /firmament/deploy directory and execute the following:
      * firmament p b -i [firmament deployment json filename]
    * Firmament will execute the commands in the firmament json file and deploy Docker-Machines to the target hypervisor
    * After creating the machines and joining them all to the Docker Swarm, Firmament will deploy all of the services
    in the firmament json file to the worker hosts.
    * The services will download the Docker images to the Docker Machine Hosts and instantiate each container requested
    * The services might take some time to start up so you can monitor those services by executing docker commands on 
    the master Docker Machine host
      * docker-machine ls (take note of the docker machine manager node name)
      * docker-machine env [manager node name]
        * run the command that it displays (eval ...)
      * Once that is done you will be sending all of your Docker commands to the manager node.
        * docker service ls\
        This command will list all of the services that have been deployed and display their replication status
    
  # Positioning Data
  
  ### Creation of Datasets
  * You may create datasets either by using the dataset creation user interface located on the stack management page or
  you can create them via our data api.  To see the api and use the data api explorer go to [any node ip]:3000/explorer
 
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
  * When you begin ETL execution the system will prepare the working area for processing by removing any previously 
  processed information from disk, the Metadata Info Catalog and the Elasticsearch Cluster.  
  * Once you have a dataset uploaded and data positioned for ETL you can begin ETL processing.  To do so you will need
  to ssh into your build server.  Once there, use "docker-machine ls -t 100" to list your docker hosts.  This will provide a
  list of docker hosts running on the system.  Each host will have an ip associated with it.  Find the staging server ip
  and "run docker-machine ssh [staging server node name]".  Once you are on the staging server you will need to exec 
  into the staging server docker container.  To do so, get the id of the docker container by running "docker ps | grep
  staging".  This will list the docker container running as the staging server.  Exec into that container by running 
  "docker exec -it [docker container id] /bin/bash".  Once there you can start your ETL process.  Navigate to "/mnt/
  merlin/merlin-etl/share/bin".  To execute the ETL process on a dataset run "run-etl [dataset id] [number of partitions,
  default=100]"
  
  ### Automatic ETL Execution
  *  An easier way to begin an ingestion is to go to the dataset page at [any node ip]:3000.  Find the dataset you are 
  wanting to ingest or re-ingest and press the "Process Dataset" button.  The state will move to queued as the system 
  starts up and will eventually move to processing and then processed.

