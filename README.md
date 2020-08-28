# Jelass (jĕl′əs), a Linearly Scalable, Searchable, NoSQL and Graph Database
## Jelass = JanusGraph + Elassandra (Elastic Search + Cassandra) 

Elassandra stores Elastic data on Cassandra. So there's no double up on this system. Cassandra is the boss. Elastic runs on top of it and allows it to be useful (searchable, querying etc.). Janus comes to town and adds all the graph functionality LinkedIn could ever need. All under the one roof.

How is this different from straight Janus? Janus' elastic data isn't stored in Cassandra. This has all 3 together. Bullet-proof. 

## Download Docker Image

https://hub.docker.com/repository/docker/sfproductlabs/jelass

### Running in docker-compose 

See example https://github.com/sfproductlabs/tracker/blob/master/docker-compose.yml

## Connecting
- `cqlsh --ssl`
- Remotely: `./bin/gremlin.sh` then `:remote connect tinkerpop.server conf/remote.yaml`
- Or locally: `./bin/gremlin.sh` then `graph = JanusGraphFactory.open('conf/gremlin-server/janusgraph-cql-es-server.properties')` 
- etc.

## Starting out
Then try the basic demo:

On the console hosting docker run:
```bash
docker ps
#then replace [container_number] with your docker container hash
docker exec -it [container_number] bash
```
Then inside the docker container:
```bash
cd /app/ela/janusgraph-full-0.5.2
./bin/gremlin.sh
```

Then inside the `gremlin>` console:

```gremlin
graph = JanusGraphFactory.open('conf/gremlin-server/janusgraph-cql-es-server.properties')
GraphOfTheGodsFactory.load(graph)
g = graph.traversal()
saturn = g.V().has('name', 'saturn').next()
g.V(saturn).valueMap()
g.V(saturn).in('father').in('father').values('name')

//Add a fulltext index on a new property alias
mgmt = graph.openManagement()
summary = mgmt.makePropertyKey('alias').dataType(String.class).make()
mgmt.buildIndex('alias', Vertex.class).addKey(summary, Mapping.TEXTSTRING.asParameter()).buildMixedIndex("search")
mgmt.commit()
g.addV('person').property('alias','bob')
g.V().has('alias', textContains('bob')).hasNext()
```
or access the data **remotely** in another remote gremlin console `./bin/gremlin.sh` (you may need to change the ip):
```
:remote connect tinkerpop.server conf/remote.yaml
:> saturn = g.V(g.V().has('name', 'saturn').next()).valueMap()
```


## Using Elassandra (Cassandra + Elastic Search)

https://elassandra.readthedocs.io/


## Visualization of Janus

To visualize graphs stored in JanusGraph, you can use any of the following
tools:

* [Arcade Analytics](https://arcadeanalytics.com/usermanual/#arcade-analytics)
* [Cytoscape](http://www.cytoscape.org/)
* [Gephi](https://tinkerpop.apache.org/docs/current/reference/#gephi-plugin)
  plugin for Apache TinkerPop
* [Graphexp](https://github.com/bricaud/graphexp)
* [Graph Explorer](https://github.com/invanalabs/graph-explorer)
* [KeyLines by Cambridge Intelligence](https://cambridge-intelligence.com/visualizing-janusgraph-new-titandb-fork/)
* [Linkurious](https://doc.linkurio.us/ogma/latest/tutorials/janusgraph/)
* [Tom Sawyer Perspectives](https://www.tomsawyer.com/perspectives/)

## Cassandra Tools

https://cassandra.apache.org/third-party/

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

## Using Python

https://docs.janusgraph.org/connecting/python/
- [ ] TODO: Connecting to spark/superset


## TODO

- [ ] TODO: Visualization in Elassandra. Superset. Spark.

## Running & Ready for Production
- [x] Docker with SSL by default
- [x] Nginx SSL for elastic search (Available on port 443 & port 9343, using nginx reverse proxy)
- [x] Cassandra client and server keystores by default
- [ ] TODO: add nginx streaming SSL for tinkerpop on 8182

### Make sure to update the replication factor of  "elastic_admin"
Ex. ```alter keyspace elastic_admin WITH replication = {'class': 'NetworkTopologyStrategy', 'DC1' : 2};```

