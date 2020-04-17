FROM jetbrains/teamcity-agent:2019.2.2

RUN curl -L \
    https://github.com/docker/compose/releases/download/1.25.4/docker-compose-`uname -s`-`uname -m` \
        > /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

