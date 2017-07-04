FROM  node:8.1

ENV SCALA_VERSION 2.11.7
ENV SBT_VERSION 0.13.15
ENV SBT_OPTS "-Xms512M -Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled"
ENV EMBER_CLI_VERSION 2.12.1
ENV BOWER_VERSION 1.8.0
ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    bzip2 \
    unzip \
    xz-utils \
    wget \
  && rm -rf /var/lib/apt/lists/*

RUN echo 'deb http://deb.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
    echo '#!/bin/sh'; \
    echo 'set -e'; \
    echo; \
    echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
  } > /usr/local/bin/docker-java-home \
  && chmod +x /usr/local/bin/docker-java-home

# do some fancy footwork to create a JAVA_HOME that's cross-architecture-safe
RUN ln -svT "/usr/lib/jvm/java-8-openjdk-$(dpkg --print-architecture)" /docker-java-home
ENV JAVA_HOME /docker-java-home

ENV JAVA_VERSION 8u131
ENV JAVA_DEBIAN_VERSION 8u131-b11-1~bpo8+1

# see https://bugs.debian.org/775775
# and https://github.com/docker-library/java/issues/19#issuecomment-70546872
ENV CA_CERTIFICATES_JAVA_VERSION 20161107~bpo8+1

RUN set -ex; \
  \
  apt-get update; \
  apt-get install -y \
    openjdk-8-jdk="$JAVA_DEBIAN_VERSION" \
    ca-certificates-java="$CA_CERTIFICATES_JAVA_VERSION" \
  ; \
  rm -rf /var/lib/apt/lists/*; \
  \
# verify that "docker-java-home" returns what we expect
  [ "$(readlink -f "$JAVA_HOME")" = "$(docker-java-home)" ]; \
  \
# update-alternatives so that future installs of other OpenJDK versions don't change /usr/bin/java
  update-alternatives --get-selections | awk -v home="$(readlink -f "$JAVA_HOME")" 'index($3, home) == 1 { $2 = "manual"; print | "update-alternatives --set-selections" }'; \
# ... and verify that it actually worked for one of the alternatives we care about
  update-alternatives --query java | grep -q 'Status: manual'

# see CA_CERTIFICATES_JAVA_VERSION notes above
RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure

# Install Scala
## Piping curl directly in tar
#RUN \
#  curl -fsL http://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /root/ && \
#  echo >> /root/.bashrc && \
#  echo 'export PATH=~/scala-$SCALA_VERSION/bin:$PATH' >> /root/.bashrc

# Install sbt
#
RUN \
  curl -L -o sbt-$SBT_VERSION.deb http://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb && \
  dpkg -i sbt-$SBT_VERSION.deb && \
  rm sbt-$SBT_VERSION.deb && \
  apt-get update && \
  apt-get install sbt
  sbt sbtVersion

# Install Bower & Ember-CLI
RUN npm i -g bower@$BOWER_VERSION ember-cli@$EMBER_CLI_VERSION

#EXPOSE 4200 35729 9000
# run ember server on container start
#ENTRYPOINT ["/usr/local/bin/ember"]
#CMD ["server"]