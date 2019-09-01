FROM ubuntu:18.04

# for correct cpu/memory detection inside a container
ENV JAVA_OPTS="-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap"
ENV GEOSERVER_HOME=/opt/geoserver
ENV GEOSERVER_DATA_DIR=/opt/geoserver/data_dir

ARG GS_VERSION=2.14.5
ARG SLF4J_VERSION=1.7.28
ARG HIKARICP_VERSION=3.3.1

ARG GS_URL=https://downloads.sourceforge.net/project/geoserver/GeoServer/${GS_VERSION}/geoserver-${GS_VERSION}-bin.zip
ARG SLF4J_URL=https://www.slf4j.org/dist/slf4j-${SLF4J_VERSION}.zip
ARG HIKARICP_FILENAME=HikariCP-${HIKARICP_VERSION}.jar
ARG HIKARICP_URL=https://search.maven.org/remotecontent?filepath=com/zaxxer/HikariCP/${HIKARICP_VERSION}/${HIKARICP_FILENAME}

WORKDIR /tmp

COPY startup-geoserver.sh /startup-geoserver.sh

RUN groupadd --gid 999 geoserver \
    && useradd --no-create-home --shell /bin/false --uid 999 --gid geoserver geoserver \
    && apt-get update && apt-get install -y \
        wget \
        unzip \
        openjdk-8-jre-headless \
    # download and extract geoserver archive
    && wget --output-document geoserver.zip "$GS_URL" \
    && unzip geoserver.zip \
    && mkdir -p "/opt" \
    && mv "geoserver-$GS_VERSION" "$GEOSERVER_HOME" \
    && chmod +x "$GEOSERVER_HOME/bin/startup.sh" \
    # clean up geoserver download
    && rm geoserver.zip \
    # add Jetty ext module to load jars from disk
    # retrieve the version which has been distributed with the downloaded geoserver version
    && JETTY_VERSION="$(ls $GEOSERVER_HOME/lib/jetty-server-*.jar | sed 's/.*jetty-server-\([0-9]\+.[0-9]\+.[0-9]\+.v[0-9]\+\)\.jar\+/\1/')" \
    && JETTY_URL=https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/${JETTY_VERSION}/jetty-distribution-${JETTY_VERSION}.zip \
    && wget --output-document jetty.zip "$JETTY_URL" \
    && unzip -j jetty.zip "jetty-distribution-$JETTY_VERSION/modules/ext.mod" -d "$GEOSERVER_HOME/modules" \
    && printf "\n--module=ext" >> "$GEOSERVER_HOME/start.ini" \
    # add Jetty mail module
    && unzip -j jetty.zip "jetty-distribution-$JETTY_VERSION/modules/mail.mod" -d "$GEOSERVER_HOME/modules" \
    && unzip -j jetty.zip "jetty-distribution-$JETTY_VERSION/lib/mail/*" -d "$GEOSERVER_HOME/lib/mail" \
    && printf "\n--module=mail" >> "$GEOSERVER_HOME/start.ini" \
    # add Jetty JNDI module - depends on server and mail
    && unzip -j jetty.zip "jetty-distribution-$JETTY_VERSION/modules/jndi.mod" -d "$GEOSERVER_HOME/modules" \
    && unzip -j jetty.zip "jetty-distribution-$JETTY_VERSION/lib/jetty-jndi-$JETTY_VERSION.jar" -d "$GEOSERVER_HOME/lib" \
    #&& unzip -j jetty.zip "jetty-distribution-$JETTY_VERSION/lib/jndi/*" -d "$GEOSERVER_HOME/lib/jndi" \
    && printf "\n--module=jndi" >> "$GEOSERVER_HOME/start.ini" \
    # add Jetty transactions module
    && unzip -j jetty.zip "jetty-distribution-$JETTY_VERSION/modules/transactions.mod" -d "$GEOSERVER_HOME/modules" \
    && unzip -j jetty.zip "jetty-distribution-$JETTY_VERSION/lib/transactions/*" -d "$GEOSERVER_HOME/lib/transactions" \
    && printf "\n--module=transactions" >> "$GEOSERVER_HOME/start.ini" \
    # add Jetty plus module for JNDI - depends on server, security, jndi, webapp, transactions
    && unzip -jo jetty.zip "jetty-distribution-$JETTY_VERSION/etc/jetty-plus.xml" -d "$GEOSERVER_HOME/etc" \
    && unzip -j jetty.zip "jetty-distribution-$JETTY_VERSION/modules/plus.mod" -d "$GEOSERVER_HOME/modules" \
    && unzip -j jetty.zip "jetty-distribution-$JETTY_VERSION/lib/jetty-plus-$JETTY_VERSION.jar" -d "$GEOSERVER_HOME/lib" \
    && printf "\n--module=plus" >> "$GEOSERVER_HOME/start.ini" \
    # Postgres driver for Jetty
    && mkdir $GEOSERVER_HOME/lib/ext \
    && cp $GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib/postgresql-*.jar $GEOSERVER_HOME/lib/ext \
    # Clean up Jetty download
    && rm jetty.zip \
    # Geoserver WPS extension
    && GS_WPS_URL=https://sourceforge.net/projects/geoserver/files/GeoServer/${GS_VERSION}/extensions/geoserver-${GS_VERSION}-wps-plugin.zip \
    && wget --output-document wps.zip "$GS_WPS_URL" \
    && unzip wps.zip -d "$GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib" \
    && rm wps.zip \
    # Geoserver CSS extension
    && GS_CSS_URL=https://sourceforge.net/projects/geoserver/files/GeoServer/${GS_VERSION}/extensions/geoserver-${GS_VERSION}-css-plugin.zip \
    && wget --output-document css.zip "$GS_CSS_URL" \
    && unzip css.zip -d "$GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib" \
    && rm css.zip \
    # 光 HikariCP for database connection pooling
    && wget --output-document geoserver/lib/ext/$HIKARICP_FILENAME "$HIKARICP_URL" \
    && wget --output-document slf4j.zip "$SLF4J_URL" \
    && unzip -j slf4j.zip "slf4j-$SLF4J_VERSION/slf4j-api-$SLF4J_VERSION.jar" -d "$GEOSERVER_HOME/lib/ext" \
    && unzip -j slf4j.zip "slf4j-$SLF4J_VERSION/slf4j-simple-$SLF4J_VERSION.jar" -d "$GEOSERVER_HOME/lib/ext" \
    && rm slf4j.zip \
    # change owner of the geoserver home directory
    && chown -R geoserver:geoserver "$GEOSERVER_HOME" \
    # clean up
    && apt-get purge -y \
        wget \
        unzip \
    && rm -rf /var/lib/apt/lists/*

USER geoserver

EXPOSE 8080
ENTRYPOINT ["/startup-geoserver.sh"]
