#!/bin/bash
set -e

# Abort if no server type is given
if [ "${1:0:1}" = '' ]; then
    echo "Aborting: No druid server type set!"
    exit 1
fi

MYSQL_CONNECT_URI="jdbc:mysql\:\/\/${MYSQL_HOST}\:${MYSQL_PORT}\/${MYSQL_DBNAME}"

sed -ri 's/druid.zk.service.host.*/druid.zk.service.host='${ZOOKEEPER_HOST}'/g' /opt/druid/conf/druid/_common/common.runtime.properties
sed -ri 's/druid.metadata.storage.connector.connectURI.*/druid.metadata.storage.connector.connectURI='${MYSQL_CONNECT_URI}'/g' /opt/druid/conf/druid/_common/common.runtime.properties
sed -ri 's/druid.metadata.storage.connector.user.*/druid.metadata.storage.connector.user='${MYSQL_USERNAME}'/g' /opt/druid/conf/druid/_common/common.runtime.properties
sed -ri 's/druid.metadata.storage.connector.password.*/druid.metadata.storage.connector.password='${MYSQL_PASSWORD}'/g' /opt/druid/conf/druid/_common/common.runtime.properties
sed -ri 's/druid.s3.accessKey.*/druid.s3.accessKey='${S3_ACCESS_KEY}'/g' /opt/druid/conf/druid/_common/common.runtime.properties
sed -ri 's/druid.s3.secretKey.*/druid.s3.secretKey='${S3_SECRET_KEY}'/g' /opt/druid/conf/druid/_common/common.runtime.properties
sed -ri 's/druid.storage.bucket.*/druid.storage.bucket='${S3_STORAGE_BUCKET}'/g' /opt/druid/conf/druid/_common/common.runtime.properties
sed -ri 's/druid.indexer.logs.s3Bucket.*/druid.indexer.logs.s3Bucket='${S3_INDEXING_BUCKET}'/g' /opt/druid/conf/druid/_common/common.runtime.properties

if [ "$DRUID_XMX" != "-" ]; then
    sed -ri 's/Xmx.*/Xmx'${DRUID_XMX}'/g' /opt/druid/conf/druid/$1/jvm.config
fi

if [ "$DRUID_XMS" != "-" ]; then
    sed -ri 's/Xms.*/Xms'${DRUID_XMS}'/g' /opt/druid/conf/druid/$1/jvm.config
fi

if [ "$DRUID_MAXNEWSIZE" != "-" ]; then
    sed -ri 's/MaxNewSize=.*/MaxNewSize='${DRUID_MAXNEWSIZE}'/g' /opt/druid/conf/druid/$1/jvm.config
fi

if [ "$DRUID_NEWSIZE" != "-" ]; then
    sed -ri 's/NewSize=.*/NewSize='${DRUID_NEWSIZE}'/g' /opt/druid/conf/druid/$1/jvm.config
fi

if [ "$DRUID_HOSTNAME" != "-" ]; then
    sed -ri 's/druid.host=.*/druid.host='${DRUID_HOSTNAME}'/g' /opt/druid/conf/druid/$1/runtime.properties
fi

if [ "$DRUID_LOGLEVEL" != "-" ]; then
    sed -ri 's/druid.emitter.logging.logLevel=.*/druid.emitter.logging.logLevel='${DRUID_LOGLEVEL}'/g' /opt/druid/conf/druid/_common/common.runtime.properties
fi

if [ "$DRUID_USE_CONTAINER_IP" != "-" ]; then
    ipaddress=`ip a|grep "global eth0"|awk '{print $2}'|awk -F '\/' '{print $1}'`
    sed -ri 's/druid.host=.*/druid.host='${ipaddress}'/g' /opt/druid/conf/druid/$1/runtime.properties
fi

java `cat /opt/druid/conf/druid/$1/jvm.config | xargs` -cp /opt/druid/conf/druid/_common:/opt/druid/conf/druid/$1:/opt/druid/lib/* io.druid.cli.Main server $@
