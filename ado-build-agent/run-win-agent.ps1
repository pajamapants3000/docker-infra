params ($pat)

$AGENT_VOLUME_NAME="ado_build_agent"
$AGENT_VOLUME_DIR="/ado_build_agent"

docker run -d `
    -e AZP_URL="https://dev.azure.com/pajamapants3000" `
    -e AZP_TOKEN="$pat" `
    -e AZP_AGENT_NAME=docker-win-1 `
    -e CONTAINER_REGISTRY="my-registry:55000" `
    -e AGENT_VOLUME_NAME=${AGENT_VOLUME_NAME} `
    -e AGENT_VOLUME_DIR=${AGENT_VOLUME_DIR} `
    --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock `
    --mount type=volume,source=${AGENT_VOLUME_NAME},target=${AGENT_VOLUME_DIR} `
    --name ado_build_agent `
    my-registry:55000/ado_build_agent:win-dotnet-1
