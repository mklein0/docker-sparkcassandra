#!/usr/bin/env bash
export SPARK_LOCAL_IP=$(awk 'END {print $1}' /etc/hosts)
cd $(realpath /usr/local/spark)
./bin/spark-shell \
	--master spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT}  \
	--conf spark.driver.host=${SPARK_LOCAL_IP} \
	--properties-file /spark-defaults.conf \
	--conf spark.cassandra.connection.host=${SPARK_LOCAL_IP} \
	--jars /spark-cassandra-connector-SNAPSHOT.jar \
	"$@"
