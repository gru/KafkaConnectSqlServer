FROM debezium/connect:1.8
ENV KAFKA_CONNECT_JDBC_DIR=$KAFKA_CONNECT_PLUGINS_DIR/kafka-connect-jdbc \
    DEBEZIUM_SCRIPTING_DIR=$KAFKA_CONNECT_PLUGINS_DIR/debezium-connector-sqlserver

ARG KAFKA_JDBC_VERSION=5.3.2
ARG DEBEZIUM_SCRIPTING_VERSION=1.8.0.Final
ARG GROOVY_VERSION=3.0.9

# Deploy Sql Server drivers
RUN cd /kafka/libs &&\ 
  curl -L 'https://download.microsoft.com/download/0/2/A/02AAE597-3865-456C-AE7F-613F99F850A8/sqljdbc_6.0.8112.200_enu.tar.gz'| tar xz &&\
  cp ./sqljdbc_6.0/enu/jre8/sqljdbc42.jar /kafka/libs &&\
  rm -rf sqljdbc_6.0

# Deploy Kafka Connect JDBC
RUN mkdir $KAFKA_CONNECT_JDBC_DIR && cd $KAFKA_CONNECT_JDBC_DIR &&\
	curl -sO https://packages.confluent.io/maven/io/confluent/kafka-connect-jdbc/$KAFKA_JDBC_VERSION/kafka-connect-jdbc-$KAFKA_JDBC_VERSION.jar

RUN cd $DEBEZIUM_SCRIPTING_DIR &&\
	curl -L https://repo1.maven.org/maven2/io/debezium/debezium-scripting/$DEBEZIUM_SCRIPTING_VERSION/debezium-scripting-$DEBEZIUM_SCRIPTING_VERSION.tar.gz | tar xz --strip-components=1 &&\
  curl -sO https://repo1.maven.org/maven2/org/codehaus/groovy/groovy/$GROOVY_VERSION/groovy-$GROOVY_VERSION.jar &&\
  curl -sO https://repo1.maven.org/maven2/org/codehaus/groovy/groovy-json/$GROOVY_VERSION/groovy-json-$GROOVY_VERSION.jar &&\
  curl -sO https://repo1.maven.org/maven2/org/codehaus/groovy/groovy-jsr223/$GROOVY_VERSION/groovy-jsr223-$GROOVY_VERSION.jar