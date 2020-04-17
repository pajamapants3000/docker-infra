docker run -d `
    -e AZP_URL="https://dev.azure.com/pajamapants3000" `
    -e AZP_TOKEN="mgscfvqtaf2o536us5uw7brifw2oxtxx6ezrnc3kqvemrxpyq2tq" `
    -e AZP_AGENT_NAME=docker-linux-1 `
    -e CONTAINER_REGISTRY="my-registry:55000" `
    --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock `
    --mount type=volume,source=ado_build_agent,target=/agent `
    my-registry:55000/ado_build_agent:linux-dotnet-docker-compose-1
