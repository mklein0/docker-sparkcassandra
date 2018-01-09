FROM cassandra:3

# Configure cassandra to listen to all rpc
RUN sed -ri ' \
	s/^(rpc_address:).*/\1 0.0.0.0/; \
	' "$CASSANDRA_CONFIG/cassandra.yaml"


ENV SPARK_VER 2.2.0
ENV HADOOP_VER 2.7
ENV SPARK_CASSANDRA_CONN_VER 2.0.5-s_2.11

# configure spark
ENV SPARK_HOME /usr/local/spark
ENV SPARK_MASTER_OPTS="-Dspark.driver.port=7001 -Dspark.fileserver.port=7002 -Dspark.broadcast.port=7003 -Dspark.replClassServer.port=7004 -Dspark.blockManager.port=7005 -Dspark.executor.port=7006 -Dspark.ui.port=4040 -Dspark.broadcast.factory=org.apache.spark.broadcast.HttpBroadcastFactory"
ENV SPARK_WORKER_OPTS=$SPARK_MASTER_OPTS
ENV SPARK_MASTER_PORT 7077
ENV SPARK_MASTER_WEBUI_PORT 8080
ENV SPARK_WORKER_PORT 8888
ENV SPARK_WORKER_WEBUI_PORT 8081

# install supervisor
RUN apt-get update && apt-get install -y supervisor wget && mkdir -p /var/log/supervisor

# download from offical repo and install spark
RUN wget -q http://central.maven.org/maven2/com/twitter/jsr166e/1.1.0/jsr166e-1.1.0.jar
RUN wget -q http://dl.bintray.com/spark-packages/maven/datastax/spark-cassandra-connector/${SPARK_CASSANDRA_CONN_VER}/spark-cassandra-connector-${SPARK_CASSANDRA_CONN_VER}.jar
RUN mirror_url=$( \
        wget -q -O - "http://www.apache.org/dyn/closer.cgi/?as_json=1" \
        | grep "preferred" \
        | sed -n 's#.*"\(http://*[^"]*\)".*#\1#p' \
        # " matching quote
        ) \
    && package_name="spark-${SPARK_VER}" \
    && wget -q -O - ${mirror_url}/spark/${package_name}/${package_name}-bin-hadoop${HADOOP_VER}.tgz \
        | tar -xzf - -C /usr/local \
    && cd /usr/local \
    && ln -s ${package_name}-bin-hadoop${HADOOP_VER} spark

RUN apt-get purge -y --auto-remove wget && rm -rf /var/lib/apt/lists/*

# configure supervisord
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# configure spark
# copy some script to run spark
COPY scripts/start-master.sh /start-master.sh
COPY scripts/start-worker.sh /start-worker.sh
COPY scripts/spark-shell.sh /spark-shell.sh
COPY scripts/spark-defaults.conf /spark-defaults.conf

RUN sed -ri " \
             s/spark-cassandra-connector-SNAPSHOT.jar/spark-cassandra-connector-${SPARK_CASSANDRA_CONN_VER}.jar/; \
        " /spark-shell.sh



COPY cassandra-configurator.sh /cassandra-configurator.sh
ENTRYPOINT ["/cassandra-configurator.sh"]

### Spark
# 4040: spark ui
# 7001: spark driver
# 7002: spark fileserver
# 7003: spark broadcast
# 7004: spark replClassServer
# 7005: spark blockManager
# 7006: spark executor
# 7077: spark master
# 8080: spark master ui
# 8081: spark worker ui
# 8888: spark worker
### Cassandra
# 7000: C* intra-node communication
# 7199: C* JMX
# 9042: C* CQL
# 9160: C* thrift service
EXPOSE 4040 7000 7001 7002 7003 7004 7005 7006 7077 7199 8080 8081 8888 9042 9160

CMD ["/usr/bin/supervisord"]
