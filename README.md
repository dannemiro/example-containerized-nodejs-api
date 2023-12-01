<!-- PROJECT -->
<br />
<div align="center">
<h2 align="center">Example of a containerized Nodejs app with Postgres</h3>
</div>




<!-- ABOUT THE PROJECT -->
## About the project


This project demonstrates how to use Docker and Docker-Compose in order to build and run a Node Js CRUD app image in a container.


Part of the requirement was to be able to pass in build arguments and set runtime variables to be able to install various packages to be run in certain environments, and have the ability to pass in runtime flags for debugging for example. The other requirements were to be able to effectively dockerize and orchestrate the runtime while providing mechanisms for adding upgrades.


The App was built with one route for a health check and simulates startup latency before sending a 200 response code after a random amount of time. I made a small change to the original app by using a json method in the response instead of plain text in order to align with best practices and the healthcheck.js was expecting a json response also.


In order to keep the container image size as secure and small as possible I used a distroless node slim version and avoided installing extra binaries. So for the health check implementation instead of installing curl I added the native Node JS code to health.js file which is invoked at a set interval here by docker-compose and tracks the container running health status.


Most of the environment variables that are needed by the app and db live in the .env file which is used only by docker-compose. There are two other required parameters that need to be set before starting up the containers. These were intentionally left out of the env file for flexibility and security. For local development they are passed in by exporting them as local environment variables. In a production environment they are managed by CICD and secret managers. See Prerequisites to get started.


I added a dockerignore to not copy extra files into the image accidently. And not to expose unneeded variables I used build ARGs and also Environment variables in docker-compose

The images are tagged with the build env ( DEV, STG, PROD)

For security I am running the app as a non-root user.




<!-- GETTING STARTED -->
## Getting Started


To get a local copy up and running follow these simple example steps.


### Prerequisites


* Make sure you have Docker and docker-compose installed and docker engine running.
* Set the database password for Postgres db and the connection string details used by the app.
 ```sh
 export PG_PASSWORD=ChangeMe!
 ```
* Set build ENV i.e. DEV, STG, or PROD will install respective packages based on env
 * DEV = installs all packages
 * STG = runs with debug enabled and node_env set to production
 * PROD = Installs imagemagick and has --production flag set as well
 ```sh
 export STAGE=DEV
 ```


### Build the app and start the db/app services


0. Run these in the root directory
1. Start everything
  ```sh
  docker-compose up -d --build app
  ```
2. Test App with rest client extension in vscode using the provided test.rest file or run the following command to see 200 or 503. Web browser works well for this by visiting http://localhost:3000/healthcheck and using dev tools.
  ```sh
  curl localhost:3000/healthcheck
  ```
3. Stop everything
  ```sh
  docker-compose down
  ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- USAGE EXAMPLES -->
## Usage


Adding packages that are not in docker
 - Example: To install wget in the Dockerfile find the section "# Install deps, extra packages and latest security patches" and append to the list of packages the wget package. Then rebuild the image.
 ```sh
 # Install deps, extra packages and latest security patches
 FROM node:20-alpine as deps
 WORKDIR /app


 RUN apk update && \
 apk upgrade && \
 apk add --no-cache wget \
 rm -rf /var/cache/apk/*
 ```
Install node packages.
- Example: Imagemagick was installed via the npm install command using the build.sh script. To add another package you can append to the npm install command in the build.sh file
```sh
  npm install imagemagick --production
```
<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Troubleshooting


Run in debug mode. By default staging build is using --debug so export stage to be STG
 ```sh
 export STAGE=STG
 ```
You can omit the -d detach flag when starting dockers via docker-compose in order to see more details about the build and runtime console debug output right in the terminal.
```sh
 docker-compose up --build app
```
Sample output
```sh
Attaching to dans-app
dans-app  | starting services with debug flag
dans-app  | Server is running on port 3000 and stage is STG
dans-app  | Healthcheck called with headers {"host":"localhost:3000","connection":"keep-alive"}
```


Use docker ps command to see if service is passing health checks by looking at the status column
```sh
 docker ps
```
Example output. notice status
```sh
CONTAINER ID   IMAGE      COMMAND                  CREATED          STATUS                                 PORTS                    NAMES
01af67b43c27   dans-app   "./docker-entrypoint…"   33 minutes ago   Up About a minute (health: starting)
CONTAINER ID   IMAGE      COMMAND                  CREATED          STATUS                        PORTS                    NAMES
01af67b43c27   dans-app   "./docker-entrypoint…"   33 minutes ago   Up About a minute (healthy)
CONTAINER ID   IMAGE      COMMAND                  CREATED         STATUS                     PORTS                    NAMES
e443dd29d802   dans-app   "./docker-entrypoint…"   6 minutes ago   Up 6 minutes (unhealthy)
```
<p align="right">(<a href="#readme-top">back to top</a>)</p>

You can also build and run this psql cli to troubleshoot db network issues. change the connection details or use the provided env file and adjust yaml.
docker-compose.yaml
```sh
version: '3.7'
services:


 pg_client:
   environment:
     - PGDATABASE=postgres
     - PGHOST=db
     - PGPORT=5432
     - PGUSER=postgres
     - PGPASSWORD=postgres
   build:
     context: .
     dockerfile: PgClientDockerfile
```
Run psql cli docker image
```sh
docker-compose -f docker-compose-psqlcli.yaml run --rm pg_client -c 'SELECT 1'
```


Common issues with build and run can be caused by not having the correct environment variable set for STAGE. Make sure to export these env vars.


<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->
## Roadmap


- [ ] Routes to create and update db data
- [ ] Tooling for troubleshooting
- [ ] Proposed features




<!-- SOURCES -->
## Sources
For this project I used the following resources. I also avoided using AI assistant in order to solidify my knwoledge further as I worked to through the scope.


Special highlight on https://www.mattknight.io/blog/docker-healthchecks-in-distroless-node-js .
I copied that entire healthcheck to be used here as a working example. I really liked the mindset that Matt has and made sense to use something that already works.


- Vscode extensions: docker, docker-compose, rest client
- https://www.mattknight.io/blog/docker-healthchecks-in-distroless-node-js
- https://github.com/othneildrew/Best-README-Template
- https://docs.docker.com/compose/
- https://docs.docker.com/build/
- https://docs.docker.com/engine/reference/commandline/run/
- https://www.docker.com/blog/how-to-use-the-postgres-docker-official-image/
- https://nodejs.org/en/download
- https://github.com/nodejs/docker-node/blob/main/README.md#how-to-use-this-image
- https://code.visualstudio.com/docs/containers/quickstart-node
- https://docs.docker.com/build/building/multi-stage/
- https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md
- https://github.com/motdotla/dotenv
- https://nodejs.org/en/docs/guides/debugging-getting-started
- https://node-postgres.com/apis/client
- https://node-postgres.com/guides/project-structure
- https://refine.dev/blog/docker-build-args-and-env-vars/#using-env-file
- https://www.docker.com/blog/how-to-use-the-postgres-docker-official-image/
- https://medium.com/@saklani1408/configuring-healthcheck-in-docker-compose-3fa6439ee280


<!-- CONTACT -->
## Contact


Dan Nemiro - dan.nemiro@gmail.com


<p align="right">(<a href="#readme-top">back to top</a>)</p>




<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[linkedin-url]: https://www.linkedin.com/in/dannemiro/
[Node.js]: https://nodejs.org/

