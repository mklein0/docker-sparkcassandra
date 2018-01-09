#!/usr/bin/env bash
export SPARK_MASTER_IP=$(awk 'END {print $1}' /etc/hosts)
export SPARK_LOCAL_IP=$(awk 'END {print $1}' /etc/hosts)
$(realpath /usr/local/spark/sbin/start-master.sh) --properties-file /spark-defaults.conf -i $SPARK_LOCAL_IP "$@"

while true
do
  sleep 10
done
