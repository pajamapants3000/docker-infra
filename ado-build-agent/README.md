# Azure DevOps Server Build Agent

## Windows
Use Dockerfile.win (e.g. rename to Dockerfile)


## Linux
Use Dockerfile.linux (e.g. rename to Dockerfile)

Let <Dockerfile> be the name of the desired Dockerfile (e.g. either Dockerfile.linux or Dockerfile.win)

1. In cmd or powershell, in this directory, run: `docker build -f <Dockerfile> -t dockeragent:latest .`
  * this will build the container, named `dockeragent` with an explicit `latest` tag
  * change name and/or tag as needed
2. Run the following command to bring up the containerized build agent:
`docker run -e AZP_URL=<Azure DevOps instance> -e AZP_TOKEN=<PAT token> -e AZP_AGENT_NAME=mydockeragent dockeragent:latest`
  * replace "mydockeragent", "dockeragent", and "latest" as appropriate
  * alternatively, use either the run-linux-agent.ps1 or run-win-agent.ps1

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

