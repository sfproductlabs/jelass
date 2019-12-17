

FROM strapdata/elassandra:6.8.4.0


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


