# merlin-stack
***
The **merlin-stack** is based upon KeyW's Parrot-Stack, a portable Spark environment. It enables you to quickly deploy a
Spark stack tailored your specific hardware or cloud resources with a minimum of DevOps experience or resources.
The Parrot-Stack utilizes Firmament, an application we've developed that uses json files to deploy services that comprise our stack.



# Stack Pre-requisites
***
The stack in its current form requires:
* a Hypervisor (Vsphere, Virtualbox, AWS EC2, Openstack)
    * Additionally AWS and Openstack need the provided **cloud-init** image
	* Virtualbox and Vsphere need the provided **boot2docker** image 
* a persistent NFS mountable network attached storage (QNAP, NFS Server, AWS Elastic Storage)
* the provided **Docker repository** containing all stack-required Docker images 

# Stack Contents
***
## Web Services
* Hadoop (Web UI)
    - location : [any node ip]:8088
    - Displays Spark cluster status; Lists all spark jobs and their status; Provides access to ETL logs 
* HDFS (Web UI)
    - location : [any node ip]:50070
    - Lists Hadoop File System nodes and status; provides file browsing within HDFS
* PostgreSQL Admin (Web UI)
    - location : [any node ip]:5050
    - Provides administration functions for the PostgreSQL database
* Merlin ETL Dashboard (Web UI)
    - location : [any node ip]:3000
    - Provides administration of Datasets, Users and Roles; Manages Datasets (ETL Kickoff) and displays ETL status updates      
* Merlin Data API Explorer (Web UI)
    - location : [any node ip]:3000/explorer
    - Provides direct access to all data in the system
* Elasticsearch Head (Web UI)
    - location : [any node ip]:9100
    - Provides management of the Elastic Cluster
* Kibana (Web UI)
    - location : [any node ip]:5601
    - Provides analysis of Elasticsearch Data
* Traefik Web Proxy (Web UI)
    - location : [any node ip]:8080
    - Displays frontend/backend proxy routes for stack
* Newman Email Analytics (Web UI)
    - location : [any node ip]:5000
    - Provides query functionality and displays email analytic results
* JupyterHub (Web UI)
    - location : [any node ip]:9999
    - Provides Python development environment for writing "on the fly" spark jobs against extracted data
## Data Services/Storage
* PostgreSQL
    - location : accessible at postgres:5432 within the stack, externally managed via the PostgreQL Admin Web UI
* Elasticsearch
    - location : Accessible at elasticsearch:9200 within the stack, externally managed via the Elasticsearch Head Web UI
## Other
* SFTP server (file transfer capability)
    - location : [any node ip]:2201  

# Building the Docker Images
***
<TBC>

# Build Server Installation and Configuration
***    
It is recommended that you create and start a linux **Build Server** VM on the target hypervisor.  The Build Server will be used to deploy the host machines and services that form the Merlin Stack.  The Build Server **MUST** have access to the Docker repository

Complete the following steps within the Build Server VM:
[ ] Install Docker version 18.03 
    **Note:** There have been issues with newer versions of Docker CE that have broken the stack.  To avoid these you should download and install only Docker CE 18.03.  **Note:** doing an apt-get update can inadvertantly update your Docker version which will break things.

[ ] Copy/Clone Parrot and Merlin Repos 
    - The Parrot repo is the base stack for the Merlin stack.  All images in the Merlin stack are built from images build in the Parrot repo.
    **Note:** The Parrot repo and Merlin repos **MUST** be located next to each other in the directory structure (there are sym-links between the two stacks).
* Copy/Clone the Parrot repo
    ```sh
    $ git clone https://<DI2E repo>/parrot-stack.git <path to clone to>
    ```
* Copy/Clone the Merlin repo next to the Parrot repo.
    ```sh
    git clone https://<DI2E repo>/merlin-stack.git <path to clone to>
    ``` 

[ ] Edit or create a new deployment json file. 
- Examples of deployment files for the various Hypervisors are located in the **merlin-stack** repo at merlin-stack/firmament/deploy (AWS, Openstack, VirtualBox, etc.)

[ ] Install NodeJs
* install nodejs
    ```sh
    $ sudo apt-get install nodejs 
    ``` 
* install npm
    ```sh
    $ sudo apt-get install npm
    ``` 
[ ] Install Firmament
**Note:** If you do not have access to the internet you will need to install Firmament on a computer connected to the internet and package it up to be moved to the target system.  Once you have installed Firmament you can use it to make a packaged version of itself by running "firmament package tar".  This will create a tar.gz file containing the entirety of the firmament application with all dependencies.
* install Firmament
    ```sh
    $ sudo npm install -g firmament
    ```
* install Firmament Docker module
    ```sh
    $ firmament module i --name docker
    ```

  ### Storage Configuration
  ***
  [ ] Ensure NFS mounts are available and match the deployment json file
    * "hadoop-datavolume": /merlin-lts\
      "hadoop-logvolume": /merlin-lts-logs\
      "postgres": /merlin-lts/db/postgresql\
      "elasticsearch0": /merlin-lts/db/es1\
      "elasticsearch1": /merlin-lts/db/es2\
      "elasticsearch2": /merlin-lts/db/es3\
      "uploads": /merlin-lts/uploads\
      "nifi-datavolume": /nifi/data
      
  ##### Directory structure
  [ ] The directory structure should all be chowned to 907:907
  [ ] The required directory structure for the NFS mount is as follows:
    * Base merlin mount folder (typically "merlin-lts")
        * db
            * es1
            * es2
            * es3
            * postgresql
        * merlin-etl
            * data
            * share\
            _The share folder contains everything required for the ETL system to run.  All configuration files, jar files, dependencies and scripts are required in a specific structure.  This folder has been provided and should be copied into the merlin-etl folder on the nfs mount prior to any stack deployment._
            * notebooks
            * uploads
    * Base merlin log mount folder (typically "merlin-lts-logs")
    * Base nifi transfer area (typically "nifi")
        * data\
            _The data folder holds all files post ETL that are filtered for NiFi_
    * location of all config files and job definitions
  
### Firmament Stack Deployment
***
    Deploying a stack requires that you be on a machine that is able to connect to the hypervisor, we suggest that it
    be a build machine VM running on the hypervisor so other team members are able to manage the stack from that VM.
    Once you have Firmament installed and the parrot-stack and merlin-stack repos available you may continue with stack deployment.    
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
  ***
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
  ***
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


