# references
# https://github.com/eliotjordan/docker-geoserver
# https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
# https://docs.geoserver.org/stable/en/user/installation/linux.html
# http://docs.geonode.org/en/master/tutorials/advanced/geonode_production/adv_gsconfig/gsproduction.html

FROM ubuntu:18.04

ENV GS_VERSION=2.14.5
ARG GS_ARCHIVE_FILENAME=geoserver-${GS_VERSION}-bin.zip
ARG GS_URL=https://downloads.sourceforge.net/project/geoserver/GeoServer/${GS_VERSION}/${GS_ARCHIVE_FILENAME}
# for correct cpu/memory detection inside a container
ENV JAVA_OPTS -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap
ENV GEOSERVER_HOME /opt/geoserver
ENV DISABLE_GEOSERVER_CONSOLE false

WORKDIR /tmp

COPY startup-geoserver-base.sh /startup-geoserver-base.sh

RUN apt-get update && apt-get install -y \
        wget \
        unzip \
    # download and extract geoserver archive
    && wget "$GS_URL" \
    && unzip "$GS_ARCHIVE_FILENAME" \
    && mkdir -p "/opt" \
    && mv "geoserver-$GS_VERSION" "$GEOSERVER_HOME" \
    && chmod +x "${GEOSERVER_HOME}/bin/startup.sh" \
    # clean up
    && rm "$GS_ARCHIVE_FILENAME" \
    && apt-get purge -y \
        wget \
        unzip \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 8080
ENTRYPOINT ["/startup-geoserver-base.sh"]