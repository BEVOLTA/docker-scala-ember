FROM frolvlad/alpine-oraclejdk8:slim

ENV SBT_VERSION=1.2.1 \
    EMBER_CLI_VERSION=3.0.0 \
    BOWER_VERSION=1.8.0 \
    LANG=C.UTF-8 \
    JQ_VERSION='1.5'

# Install libs needed by CircleCI
RUN apk add --no-cache --update bash git openssh tar zip xz nodejs nodejs-npm bc

# Install ember and bower
RUN npm i -g bower@$BOWER_VERSION ember-cli@$EMBER_CLI_VERSION

# Install sbt
RUN apk add --no-cache --virtual=build-dependencies curl && \
    curl -sL "https://github.com/sbt/sbt/releases/download/v$SBT_VERSION/sbt-$SBT_VERSION.tgz" | gunzip | tar -x -C /usr/local && \
    ln -s /usr/local/sbt/bin/sbt /usr/local/bin/sbt && \
    chmod 0755 /usr/local/bin/sbt && \
    apk del build-dependencies && \
    sbt sbtVersion

# Install AWSEBCLI
RUN apk --no-cache add py-pip groff less && \
    pip install --upgrade pip awsebcli && \
    rm -rf /tmp/* /root/.cache

# Install jq command-line json library
RUN apk --no-cache add wget ca-certificates gnupg && \
    wget --no-check-certificate https://raw.githubusercontent.com/stedolan/jq/master/sig/jq-release.key -O /tmp/jq-release.key && \
    wget --no-check-certificate https://raw.githubusercontent.com/stedolan/jq/master/sig/v${JQ_VERSION}/jq-linux64.asc -O /tmp/jq-linux64.asc && \
    wget --no-check-certificate https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 -O /tmp/jq-linux64 && \
    gpg --import /tmp/jq-release.key && \
    gpg --verify /tmp/jq-linux64.asc /tmp/jq-linux64 && \
    cp /tmp/jq-linux64 /usr/bin/jq && \
    chmod +x /usr/bin/jq && \
    rm -rf /tmp/* /root/.cache

# Install ECS Deploy
RUN wget  --no-check-certificate https://raw.githubusercontent.com/silinternational/ecs-deploy/master/ecs-deploy -O /usr/bin/ecs-deploy  && \
    chmod +x /usr/bin/ecs-deploy