# Docker Cassandra Spark

Cassandra / Spark Container built on Open Source binary distributions.  Dockerfile based on techniques found in
https://github.com/clakech/sparkassandra-dockerized.git and https://github.com/smizy/docker-apache-phoenix.git.


## Install docker and git
* https://docs.docker.com/installation/
* https://git-scm.com/book/en/v2/Getting-Started-Installing-Git

## Run your own Spark + Cassandra cluster using Docker!

TODO: Maybe add docker-compose file here.


Here you have a Cassandra + Spark cluster running without installing anything but Docker. #cool

## Try your Cassandra cluster

## Try your Cassandra cluster

To test your Cassandra cluster, you can run a cqlsh console to insert some data:

```
# run a Cassandra cqlsh console
docker run -it --link some-cassandra:cassandra --rm clakech/sparkassandra-dockerized cqlsh cassandra

# create some data and retrieve them:
cqlsh>CREATE KEYSPACE test WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1 };

cqlsh>CREATE TABLE test.kv(key text PRIMARY KEY, value int);

cqlsh>INSERT INTO test.kv(key, value) VALUES ('key1', 1);

cqlsh>INSERT INTO test.kv(key, value) VALUES ('key2', 2);

cqlsh>SELECT * FROM test.kv;

 key  | value
------+-------
 key1 |     1
 key2 |     2

(2 rows)
```

## Try your Spark cluster

To test your Spark cluster, you can run a shell to read/write data from/to Cassandra:

```
# run a Spark shell
docker run -i -t -P --link spark-master:spark-master --link some-cassandra:cassandra clakech/sparkassandra-dockerized /spark-shell.sh

# check you can retrieve your Cassandra data using Spark
scala> import com.datastax.spark.connector._
...
scala> val rdd = sc.cassandraTable("test", "kv")
rdd: com.datastax.spark.connector.rdd.CassandraTableScanRDD[com.datastax.spark.connector.CassandraRow] = CassandraTableScanRDD[0] at RDD at CassandraRDD.scala:15

scala> println(rdd.count)
2

scala> println(rdd.first)
CassandraRow{key: key1, value: 1}

scala> println(rdd.map(_.getInt("value")).sum)
3.0

scala> val collection = sc.parallelize(Seq(("key3", 3), ("key4", 4)))
collection: org.apache.spark.rdd.RDD[(String, Int)] = ParallelCollectionRDD[4] at parallelize at <console>:24

scala> collection.saveToCassandra("test", "kv", SomeColumns("key", "value"))
...

scala> println(rdd.map(_.getInt("value")).sum)
10.0


// https://github.com/datastax/spark-cassandra-connector/blob/master/doc/14_data_frames.md

scala> import com.datastax.spark.connector._
import com.datastax.spark.connector._

scala> val df = spark.read.format("org.apache.spark.sql.cassandra").options(Map("table" -> "kv", "keyspace" -> "test")).load
df: org.apache.spark.sql.Dataset[org.apache.spark.sql.Row] = [key: string, value: int]

scala> df.createTempView("test_kv")

scala> val sqldf = spark.sql("SELECT * FROM test_kv")
sqldf: org.apache.spark.sql.DataFrame = [key: string, value: int]

scala> sqldf.show
+----+-----+
| key|value|
+----+-----+
|key1|    1|
|key2|    2|
+----+-----+

scala> spark.sql("SELECT SUM(value) FROM test_kv").show
+----------+
|sum(value)|
+----------+
|         3|
+----------+
```
