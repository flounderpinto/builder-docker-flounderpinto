# Builder Docker Flounderpinto
A script to standardize and automate building flounderpinto Docker images.

## Description
This repo creates a Docker image that contains the dockerBuild.sh script from https://github.com/flounderpinto/builder-docker.  This Docker image contains this projects Docker CLI version as well as the Docker Registry location (index.docker.io/flounderpinto). 

## Usage

### Makefile Docker example
The commands to execute the script via a Docker container can be contained in a Makefile for ease of execution by either a human or a build pipeline.

```Makefile
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

CONTAINER_CODE_DIR=/opt/code

DOCKER_REGISTRY=index.docker.io/flounderpinto

DOCKER_REPO=builder-bash
DOCKER_BUILD_BRANCH_CMD=dockerBuildStandardBranch -r ${DOCKER_REPO} ${ARGS}
DOCKER_BUILD_MAIN_CMD=dockerBuildStandardMain -r ${DOCKER_REPO} ${ARGS}
DOCKER_BUILD_TAG_CMD=dockerBuildStandardTag ${TAG} -r ${DOCKER_REPO} ${ARGS}
DOCKER_BUILDER_IMAGE=${DOCKER_REGISTRY}/builder-docker-flounderpinto:<TODO-VERSION>
DOCKER_BUILDER_PULL_CMD=docker pull ${DOCKER_BUILDER_IMAGE}
DOCKER_BUILDER_RUN_CMD=${DOCKER_BUILDER_PULL_CMD} && \
    docker run \
        --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v ${HOME}/.docker:/tmp/.docker:ro \
        -v ${ROOT_DIR}:${CONTAINER_CODE_DIR} \
        ${DOCKER_BUILDER_IMAGE}

.PHONY: docker docker_main docker_tag

docker:
	${DOCKER_BUILDER_RUN_CMD} ${DOCKER_BUILD_BRANCH_CMD}

docker_main:
	${DOCKER_BUILDER_RUN_CMD} ${DOCKER_BUILD_MAIN_CMD}

docker_tag:
	test ${TAG}
	${DOCKER_BUILDER_RUN_CMD} ${DOCKER_BUILD_TAG_CMD}

#Everything right of the pipe is order-only prerequisites.
all: | docker
```

### GitHub workflow example
```yaml
name: CI

on:
  push:
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.TODO }}#TODO - Insert username secret name here
          password: ${{ secrets.TODO }}#TODO - Insert access token secret name here

      - name: Docker build branch
        run: make docker
        if: ${{ github.ref_type == 'branch' && github.ref_name != 'main' }}

      - name: Docker build main
        run: make docker_main
        if: ${{ github.ref_type == 'branch' && github.ref_name == 'main' }}

      - name: Docker build tag
        run: make docker_tag TAG="${{github.ref_name}}"
        if: ${{ github.ref_type == 'tag' }}
```

## License
Distributed under the MIT License. See `LICENSE.txt` for more information.