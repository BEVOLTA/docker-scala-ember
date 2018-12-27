FROM frolvlad/alpine-oraclejdk8:slim

ENV SBT_VERSION=1.2.1 \
    EMBER_CLI_VERSION=3.4.3 \
    LANG=C.UTF-8 \
    JQ_VERSION='1.5' \
    DOCKER_VERSION=17.03.0-ce

# Install libs needed by CircleCI
RUN apk add --no-cache --update bash git openssh tar zip xz nodejs-current nodejs-npm bc ca-certificates wget gnupg py-pip groff less docker

#RUN wget --no-check-certificate https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_VERSION.tgz -O /tmp/docker-$DOCKER_VERSION.tgz && \
#            tar -xz -C /tmp -f /tmp/docker-$DOCKER_VERSION.tgz && \
#            mv /tmp/docker/* /usr/bin && \
#            service docker start

# Install ember and bower
RUN npm i -g ember-cli@$EMBER_CLI_VERSION

# Install sbt
RUN apk add --no-cache --virtual=build-dependencies curl && \
    curl -sL "https://github.com/sbt/sbt/releases/download/v$SBT_VERSION/sbt-$SBT_VERSION.tgz" | gunzip | tar -x -C /usr/local && \
    ln -s /usr/local/sbt/bin/sbt /usr/local/bin/sbt && \
    chmod 0755 /usr/local/bin/sbt && \
    apk del build-dependencies && \
    sbt sbtVersion

# Install AWSEBCLI
RUN pip install --upgrade pip awsebcli && \
    rm -rf /tmp/* /root/.cache

# Install jq command-line json library
RUN wget --no-check-certificate https://raw.githubusercontent.com/stedolan/jq/master/sig/jq-release.key -O /tmp/jq-release.key && \
    wget --no-check-certificate https://raw.githubusercontent.com/stedolan/jq/master/sig/v${JQ_VERSION}/jq-linux64.asc -O /tmp/jq-linux64.asc && \
    wget --no-check-certificate https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 -O /tmp/jq-linux64 && \
    gpg --import /tmp/jq-release.key && \
    gpg --verify /tmp/jq-linux64.asc /tmp/jq-linux64 && \
    cp /tmp/jq-linux64 /usr/bin/jq && \
    chmod +x /usr/bin/jq && \
    rm -rf /tmp/* /root/.cache

# Install ECS Deploy
#RUN wget  --no-check-certificate https://raw.githubusercontent.com/silinternational/ecs-deploy/master/ecs-deploy -O /usr/bin/ecs-deploy  && \
#    chmod +x /usr/bin/ecs-deploy