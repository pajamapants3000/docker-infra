param (
    [string]$HostOs = "Linux",  # Currently supports "Linux" (default) or "Windows"
    [string]$Pat                # Personal Access Token
)

# TODO: Make a proper CMDlet

# Define Constants #
$AGENT_VOLUME_NAME = "ado_build_agent"
$DOCKER_HOST = "tcp://0.0.0.0:2375"

## Windows Agent ##
$AZP_AGENT_NAME_WIN = "docker-win-1"
$AGENT_CONTAINER_NAME_WIN = "ado_build_agent-win"
$AGENT_BUILD_TAG_WIN = "win-dotnet-docker-compose-1"
$DOCKERFILE_WIN = "Dockerfile.win"
$MY_REGISTRY_HOST_WIN = ""
$MY_REGISTRY_PORT_WIN = ""
$ADDITIONAL_DOCKER_RUN_ARGUMENTS_WIN = "DOCKER_HOST=tcp://0.0.0.0:2375"
$DIR_ROOT_WIN = "C:/Volumes/"
## End Windows Agent ##

## Linux Agent ##
$AZP_AGENT_NAME_LINUX = "docker-linux-1"
$AGENT_CONTAINER_NAME_LINUX = "ado_build_agent-linux"
$AGENT_BUILD_TAG_LINUX = "linux-dotnet-docker-compose-1"
$DOCKERFILE_LINUX = "Dockerfile.linux"
$MY_REGISTRY_HOST_LINUX = "my-registry"
$MY_REGISTRY_PORT_LINUX = "55000"
$ADDITIONAL_DOCKER_RUN_ARGUMENTS_LINUX = `
    "--mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock"
$DIR_ROOT_LINUX = "/"
## End Windows Agent ##

# End Define Constants #

# Set HostOs-specific values
if ($HostOs -eq "Linux") {
    $AZP_AGENT_NAME = $AZP_AGENT_NAME_LINUX
    $AGENT_CONTAINER_NAME = $AGENT_CONTAINER_NAME_LINUX
    $AGENT_BUILD_TAG = $AGENT_BUILD_TAG_LINUX
    $DOCKERFILE = $DOCKERFILE_LINUX

    $MY_REGISTRY_HOST = $MY_REGISTRY_HOST_LINUX
    $MY_REGISTRY_PORT = $MY_REGISTRY_PORT_LINUX
    $ADDITIONAL_DOCKER_RUN_ARGUMENTS = $ADDITIONAL_DOCKER_RUN_ARGUMENTS_LINUX
    $DIR_ROOT = $DIR_ROOT_LINUX
}
elseif ($HostOs -eq "Windows") {
    $AZP_AGENT_NAME = $AZP_AGENT_NAME_WIN
    $AGENT_CONTAINER_NAME = $AGENT_CONTAINER_NAME_WIN
    $AGENT_BUILD_TAG = $AGENT_BUILD_TAG_WIN
    $DOCKERFILE = $DOCKERFILE_WIN

    $MY_REGISTRY_HOST = $MY_REGISTRY_HOST_WIN
    $MY_REGISTRY_PORT = $MY_REGISTRY_PORT_WIN
    $ADDITIONAL_DOCKER_RUN_ARGUMENTS = $ADDITIONAL_DOCKER_RUN_ARGUMENTS_WIN
    $DIR_ROOT = $DIR_ROOT_WIN
}
else
{
    throw "Invalid HostOs value: $HostOs"
}

$AGENT_VOLUME_DIR = "${DIR_ROOT}${AGENT_VOLUME_NAME}"

$ScriptPath = Split-Path $MyInvocation.MyCommand.Path
if ($MY_REGISTRY_HOST -ne "")
{
    $AgentImageTag = "{0}:{1}/{2}:{3}" `
        -f ${MY_REGISTRY_HOST}, ${MY_REGISTRY_PORT}, `
            ${AGENT_CONTAINER_NAME}, ${AGENT_BUILD_TAG}
}
else
{
    $AgentImageTag = "{0}:{1}" -f ${AGENT_CONTAINER_NAME}, ${AGENT_BUILD_TAG}
}

docker build `
    -f $ScriptPath/${DOCKERFILE} `
    -t $AgentImageTag `
    $ScriptPath

if ($lastexitcode -ne 0) {
    throw "docker build: " + $errorMessage
}

if ($MY_REGISTRY_HOST -ne "")
{
    docker push $AgentImageTag

    if ($lastexitcode -ne 0) {
        throw "docker push: " + $errorMessage
    }
}

docker ps -a | findstr $AGENT_CONTAINER_NAME | Out-Null
if ($lastexitcode -eq 0) {
    docker rm -f $AGENT_CONTAINER_NAME
}

docker run -d `
    -e AZP_URL="https://dev.azure.com/pajamapants3000" `
    -e AZP_TOKEN="$Pat" `
    -e AZP_AGENT_NAME=${AZP_AGENT_NAME} `
    -e CONTAINER_REGISTRY="${MY_REGISTRY_HOST}:${MY_REGISTRY_PORT}" `
    -e AGENT_VOLUME_NAME=${AGENT_VOLUME_NAME} `
    -e AGENT_VOLUME_DIR=${AGENT_VOLUME_DIR} `
    -e DOCKER_HOST=$DOCKER_HOST `
    --mount type=volume,source=${AGENT_VOLUME_NAME},target=${AGENT_VOLUME_DIR} `
    --name ${AGENT_CONTAINER_NAME} `
    ${AgentImageTag}

if ($lastexitcode -ne 0) {
    throw "docker run: " + $errorMessage
}

