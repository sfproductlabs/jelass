# Jelass, a Linearly Scalable, Searchable, NoSQL and Graph Database combined in one

## Janus + Elassandra (Elastic Search + Cassandra) 

Elassandra stores Elastic data on Cassandra. So there's no double up on this system. Cassandra is the boss. Elastic runs on top of it and allows it to be useful (searchable, querying etc.). Janus comes to town and adds all the graph functionality LinkedIn could ever need. All under the one roof.

How is this different from straight Janus? Elastic data isn't stored in Cassandra. This has all 3 together. Bullet-proof. 

## Download Docker Image

https://hub.docker.com/repository/docker/sfproductlabs/jelass

## Running & Ready for Production
- [x] Docker with SSL by default
- [x] Nginx SSL for elastic search (Available on port 443 & port 9343, using nginx reverse proxy)
- [x] Cassandra client and server keystores by default
- [ ] TODO: add nginx streaming SSL for tinkerpop on 8182

## Connecting
- `cqlsh --ssl`
- `:remote connect tinkerpop.server conf/remote.yaml`
- etc.

## Diagnostics

```bash
curl -XGET http://$CASSANDRA_HOST:9200/_cluster/state?pretty
nodetool repair -full
nodetool cleanup
nodetool flush
#nodetool rebuild_index sfpla events_recent events_recent_idx
nodetool gossipinfo
nodetool tpstats
nodetool describecluster
nodetool statusthrift
nodetool statusgossip
nodetool ring
nodetool status
nodetool status elastic_admin
#less /var/log/cassandra/system.log
# ...
#cqlsh --ssl
#cqlsh>select * from elastic_admin.Metadata_log;
```