

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

# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
# 9142 : encrypted CQL
# 9160: thrift service
# 9200: elassandra HTTP
# 9300: elasticsearch transport
EXPOSE 7000 7001 7199 9042 9142 9160 9200 9300
CMD ["cassandra", "-f"]


