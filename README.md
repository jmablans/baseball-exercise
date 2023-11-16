# Baseball Exercise

Data Engineering exercise roughly following the steps described [here](https://gist.github.com/bcm/026b4b2d4499001979970b4f23b4183d). Goal is to demonstrate R coding. 

### Prerequisite instructions

- Clone this repository.
- Run a local PostgreSql DB by following the steps in [postgres-server.md](postgres-server.md). Docker is needed for this. 
- Make sure you have R installed, including the following libraries:
  - library(DBI)
  - RPostgres 
  - data.table
  - aws.s3

### Execution instructions
1. Make sure the PostgreSql DB from the prerequisite steps is running. 
2. Run the [data provisioning](data_provisioning.R) R script to download the data from the internet and load it into the DB.
3. Run the [processing](processing.R) R script that runs an example analysis query and uploads the result to an AWS S3 bucket.
 
