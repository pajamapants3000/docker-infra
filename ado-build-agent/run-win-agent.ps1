docker run -d \
    -e AZP_URL="https://dev.azure.com/pajamapants3000" \
    -e AZP_TOKEN="mgscfvqtaf2o536us5uw7brifw2oxtxx6ezrnc3kqvemrxpyq2tq" \
    -e AZP_AGENT_NAME=docker-win-1 \
    -e CONTAINER_REGISTRY="my-registry:55000" \
    my-registry:55000/ado_build_agent:win-dotnet-1
