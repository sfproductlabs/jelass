

FROM strapdata/elassandra:6.8.4.0

WORKDIR /app/ela
ADD . /app/ela

COPY cassandra.yaml /etc/cassandra/cassandra.yaml
COPY .cassandra/cqlshrc /root/.cassandra/cqlshrc

####################################################################################

# ulimit increase (set in docker templats/aws ecs-task-definition too!!)
RUN bash -c 'echo "root hard nofile 1048575" >> /etc/security/limits.conf' \
 && bash -c 'echo "root soft nofile 1048575" >> /etc/security/limits.conf' \
 && bash -c 'echo "* hard nofile 1048575" >> /etc/security/limits.conf' \
 && bash -c 'echo "* soft nofile 1048575" >> /etc/security/limits.conf' \
 && bash -c 'echo "cassandra soft memlock unlimited" >> /etc/security/limits.conf' \
 && bash -c 'echo "cassandra hard memlock unlimited" >> /etc/security/limits.conf' 
 
# ip/tcp tweaks, disable ipv6
RUN bash -c 'echo "net.core.somaxconn = 1048575" >> /etc/sysctl.conf' \
 && bash -c 'echo "net.ipv4.tcp_max_tw_buckets = 1440000" >> /etc/sysctl.conf' \
 && bash -c 'echo "net.ipv4.tcp_window_scaling = 1" >> /etc/sysctl.conf' \
 && bash -c 'echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf' \
 && bash -c 'echo "net.ipv4.tcp_max_syn_backlog = 1048575" >> /etc/sysctl.conf' \
 && bash -c 'echo "fs.file-max=1048575" >> /etc/sysctl.conf' \
 && bash -c 'echo "vm.max_map_count=1048575" >> /etc/sysctl.conf' 

####################################################################################



RUN apt update && apt upgrade -y && \
    apt install unzip wget nginx libnginx-mod-stream -y && \
    cp nginx.conf /etc/nginx/ && \
    service nginx start && \
    /usr/sbin/update-rc.d -f nginx defaults

ENV JANUS 0.5.2
ENV JV janusgraph-full-${JANUS}
RUN wget https://github.com/JanusGraph/janusgraph/releases/download/v${JANUS}/${JV}.zip
RUN unzip ${JV}.zip 
RUN bash -c 'echo "storage.cql.ssl.enabled=true" >> $JV/conf/gremlin-server/janusgraph-cql-es-server.properties' \
 && bash -c 'echo "storage.cql.ssl.client-authentication-enabled=true" >> $JV/conf/gremlin-server/janusgraph-cql-es-server.properties' \
 && bash -c 'echo "storage.cql.ssl.keystore.keypassword=YInKGOL6P7kzJCx" >> $JV/conf/gremlin-server/janusgraph-cql-es-server.properties' \
 && bash -c 'echo "storage.cql.ssl.keystore.location=/app/ela/.setup/keys/cassandra-server.jks" >> $JV/conf/gremlin-server/janusgraph-cql-es-server.properties' \
 && bash -c 'echo "storage.cql.ssl.keystore.storepassword=YInKGOL6P7kzJCx" >> $JV/conf/gremlin-server/janusgraph-cql-es-server.properties' \
 && bash -c 'echo "storage.cql.ssl.truststore.location=/app/ela/.setup/keys/cassandra-truststore.jks" >> $JV/conf/gremlin-server/janusgraph-cql-es-server.properties' \
 && bash -c 'echo "storage.cql.ssl.truststore.password=YInKGOL6P7kzJCx" >> $JV/conf/gremlin-server/janusgraph-cql-es-server.properties' 

# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
# 9142 : encrypted CQL
# 9160: thrift service
# 9200: elassandra HTTP # Remove for security
# 9300: elasticsearch internal transport
# 9343: elasticsearch internal transport (encrypted)
# 443: HTTPS 9200 (NGINX Proxy)
# 80: HTTP->HTTPS REDIRECT
EXPOSE 7000 7001 7199 9042 9142 9160 9200 9300 9343 443 80
#CMD service nginx start ; runuser -m -l cassandra -c "cassandra -f"
#CMD ["cassandra", "-f"]
CMD bash -c "((sleep 60s && $JV/bin/gremlin-server.sh $JV/conf/gremlin-server/gremlin-server-cql-es.yaml &) && runuser -m cassandra -c 'cassandra -f')"

