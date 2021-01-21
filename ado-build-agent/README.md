# Azure DevOps Server Build Agent #

## Docker Registry ##
Add the following line to your hosts file (C:\Windows\System32\drivers\etc\hosts)
  * `my-registry 127.0.0.1`
Alternatively, change the CONTAINER_REGISTRY environment variable passed to
run-X-agent.ps1 to point to whatever registry you want (e.g. your
DockerHub registry)
TODO: make this a parameter you can pass to the run script
##

## Windows ##
Use Dockerfile.win
##

## Linux
Use Dockerfile.linux

Note: May occasionally need to update Ubuntu base image version. When this
happens, may also need to update package versions.

IMPORTANT: start.sh must use unix line endings ('fileformat'=unix in vim)
##

## Short Instructions ##
$> .\restore-agent.ps1 [-HostOs [Linux|Windows]] -Pat <PAT>

Note that -HostOs is optional - defaults to Linux

This will build and push the image to the local registry, then start the container.
## End Short Instructions ##

## Long Instructions ##

Let <Dockerfile> be the name of the desired Dockerfile (e.g. either Dockerfile.linux or Dockerfile.win)

1. In cmd or powershell, in this directory, run: `docker build -f <Dockerfile> -t ado_build_agent:latest .`
  * this will build the container, named `dockeragent` with an explicit `latest` tag
  * change name and/or tag as needed (instead of "latest", should be e.g. "linux-dotnet-docker-compose-1")
2. Run the following command to bring up the containerized build agent:
`docker run -e AZP_URL=<Azure DevOps instance> -e AZP_TOKEN=<PAT token> -e AZP_AGENT_NAME=mydockeragent ado_build_agent:latest`
  * replace "mydockeragent", "dockeragent", and "latest" as appropriate
  * change name and/or tag as needed (instead of "latest", should be e.g. "linux-dotnet-docker-compose-1")

See https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops#windows for more details.

## Environment Variables
<table>
  <tr>
    <td>AZP_URL</td>
    <td>The URL of the Azure DevOps or Azure DevOps Server instance</td>
  </tr>
  <tr>
    <td>AZP_TOKEN</td>
    <td>Personal Access Token (PAT) granting access to</td>
  </tr>
  <tr>
    <td>AZP_AGENT_NAME</td>
    <td>Agent name (default value: the container hostname)</td>
  </tr>
  <tr>
    <td>AZP_POOL</td>
    <td>Agent pool name (default value: Default)</td>
  </tr>
  <tr>
    <td>AZP_WORK</td>
    <td>Work directory (default value: _work)</td>
  </tr>
</table>
## End Long Instructions ##

