DOCKER_REGISTRY=index.docker.io/flounderpinto
DOCKER_REPO=builder-docker-flounderpinto

INIT_CMD=git submodule update --init --recursive

DOCKER_BUILD_SCRIPT=./builder-docker/src/dockerBuild.sh
DOCKER_BUILD_BRANCH_CMD=${DOCKER_BUILD_SCRIPT} dockerBuildStandardBranch \
    -b REGISTRY=${DOCKER_REGISTRY} \
    -e ${DOCKER_REGISTRY} \
    -r ${DOCKER_REPO} \
    ${ARGS}
DOCKER_BUILD_MAIN_CMD=${DOCKER_BUILD_SCRIPT} dockerBuildStandardMain \
    -b REGISTRY=${DOCKER_REGISTRY} \
    -e ${DOCKER_REGISTRY} \
    -r ${DOCKER_REPO} \
    ${ARGS}
DOCKER_BUILD_TAG_CMD=${DOCKER_BUILD_SCRIPT} dockerBuildStandardTag \
    ${TAG} \
    -b REGISTRY=${DOCKER_REGISTRY} \
    -e ${DOCKER_REGISTRY} \
    -r ${DOCKER_REPO} \
    ${ARGS}

.PHONY: init docker docker_main docker_tag

init:
	${INIT_CMD}

docker:
	${DOCKER_BUILD_BRANCH_CMD}

docker_main:
	${DOCKER_BUILD_MAIN_CMD}

docker_tag:
	test ${TAG}
	${DOCKER_BUILD_TAG_CMD}

all: | init docker
