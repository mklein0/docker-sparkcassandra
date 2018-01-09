#!/usr/bin/env bash
export SPARK_LOCAL_IP=$(awk 'END {print $1}' /etc/hosts)
cd /usr/local/spark
./bin/spark-shell \
	--master spark://${SPARK_MASTER_HOST}  \
	--conf spark.driver.host=${SPARK_LOCAL_IP} \
	--properties-file /spark-defaults.conf \
	--jars /spark-cassandra-connector-assembly-1.3.0-RC1-SNAPSHOT.jar \
	--conf spark.cassandra.connection.host=${SPARK_LOCAL_IP} \
	"$@"
