# Local PostgreSQL Server

Run a local server using Docker, use the following steps:

### Prerequisites

- Install Docker

### Steps

1. Run `docker pull postgres` . This should download the latest version of the Postgres docker image.
2. Run the Docker image by `docker run -d --name postgresCont -p 5432:5432 -e POSTGRES_PASSWORD=password123 postgres`. 
  - `-d` flag specifies that the container should execute in the background.
  - `--name` option assigns the container’s name, i.e., “postgresCont”.
  - `-p` assigns the port for the container i.e. “5432:5432”.
  - `-e POSTGRES_PASSWORD` configures the password to be “password123”.
  - `postgres` is the official Docker image.
3. Enter the container to setup the database by running `docker exec -it postgresCont bash`.
4. In the container bash start Postgres by running `psql -h localhost -U postgres`.
5. Lastly create a DB by `CREATE DATABASE baseball;`

