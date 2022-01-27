printf "\nBuilding debezium-sqlserver-jdbc-sink\n"
docker build -t debezium-sqlserver-jdbc-sink -f debezium-sqlserver-jdbc-sink/Dockerfile .

printf "\nStarting services\n"
docker-compose -f docker-compose-sqlserver.yaml up -d

printf "\nWaiting services to start...\n"
sleep 15s

printf "\nInit source db...\n"
cat debezium-sqlserver-init/source.sql      | docker-compose -f docker-compose-sqlserver.yaml exec -T sqlserver bash -c '/opt/mssql-tools/bin/sqlcmd -U sa -P $SA_PASSWORD'
printf "\nInit destination db...\n"
cat debezium-sqlserver-init/destination.sql | docker-compose -f docker-compose-sqlserver.yaml exec -T sqlserver bash -c '/opt/mssql-tools/bin/sqlcmd -U sa -P $SA_PASSWORD'

curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @register-sqlserver.json
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @register-sqlserver-sink.json

printf "\nKafka topics\n"
docker-compose -f docker-compose-sqlserver.yaml exec kafka bin/kafka-topics.sh --list --bootstrap-server kafka:9092

printf "\nSource data\n"
docker-compose -f docker-compose-sqlserver.yaml exec -T sqlserver bash -c '/opt/mssql-tools/bin/sqlcmd -U sa -P $SA_PASSWORD -d testDB -Q "select * from customers"'

printf "\nDestination data\n"
docker-compose -f docker-compose-sqlserver.yaml exec -T sqlserver bash -c '/opt/mssql-tools/bin/sqlcmd -U sa -P $SA_PASSWORD -d destinationDB -Q "select * from customers"'

# Modify records in the database via SQL Server client (do not forget to add `GO` command to execute the statement)
# docker-compose -f docker-compose-sqlserver.yaml exec sqlserver bash -c '/opt/mssql-tools/bin/sqlcmd -U sa -P $SA_PASSWORD -d testDB'