SQLSERVER_DRIVERS_TMP_DIR=sqljdbc
KAFKA_LIBS_DIR=libs
CONFLUENT_HUB_DIR=confluent-hub
CONNECT_PLUGINS_DIR=$(pwd)/plugins
CONNECT_CONFIG=config/connect-distributed.properties
DEBEZIUM_CONFIG=config/test-debezium-sqlserver-source.properties
JDBC_CONFIG=config/test-jdbc-sink.properties

mkdir $SQLSERVER_DRIVERS_TMP_DIR
curl -L "https://download.microsoft.com/download/4/d/5/4d5a79be-35f8-48d4-a984-473747362f99/sqljdbc_10.2.0.0_enu.tar.gz" | tar xz -C $SQLSERVER_DRIVERS_TMP_DIR --strip-components=1
cp $SQLSERVER_DRIVERS_TMP_DIR/enu/mssql-jdbc-10.2.0.jre11.jar $KAFKA_LIBS_DIR/mssql-jdbc-10.2.0.jre11.jar
rm -rf $SQLSERVER_DRIVERS_TMP_DIR

mkdir $CONFLUENT_HUB_DIR
curl -L "http://client.hub.confluent.io/confluent-hub-client-latest.tar.gz" | tar xz -C $CONFLUENT_HUB_DIR

export PATH=$CONFLUENT_HUB_DIR/bin:$PATH

mkdir $CONNECT_PLUGINS_DIR
yes | confluent-hub install confluentinc/kafka-connect-jdbc:10.3.1 --component-dir $CONNECT_PLUGINS_DIR --worker-configs $CONNECT_CONFIG
yes | confluent-hub install debezium/debezium-connector-sqlserver:1.7.1 --component-dir $CONNECT_PLUGINS_DIR --worker-configs $CONNECT_CONFIG

cat << EOF > $DEBEZIUM_CONFIG
name=test-debezium-sqlserver-source
connector.class=io.debezium.connector.sqlserver.SqlServerConnector
tasks.max=1
database.hostname=
database.port=
database.user=
database.password=
database.dbname=
database.server.name=test_source
database.history.kafka.bootstrap.servers=localhost:9092
database.history.kafka.topic=test_source_schema_changes
EOF

cat << EOF > $JDBC_CONFIG
name=test-jdbc-sink
connector.class=io.confluent.connect.jdbc.JdbcSinkConnector
tasks.max=1
connection.url=
connection.user=
connection.password=
transforms=unwrap,route
transforms.unwrap.type=io.debezium.transforms.ExtractNewRecordState
transforms.unwrap.drop.tombstones=false
transforms.route.type=org.apache.kafka.connect.transforms.RegexRouter
transforms.route.regex=([^.]+)\\.([^.]+)\\.([^.]+)
transforms.route.replacement=$3
insert.mode=upsert
delete.enabled=true
pk.mode=record_key
topics=test_source.dbo.customers
EOF

bin/connect-distributed.sh $CONNECT_CONFIG $DEBEZIUM_CONFIG $JDBC_CONFIG