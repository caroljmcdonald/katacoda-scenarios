The [MapR Database](https://mapr.com/products/mapr-db/) is a scalable, high performance, NoSQL database designed for data-intensive applications. 

CRUD operations can be performed programmatically using Python, Java, and Node.js, or with command-line utilities, as demonstrated below.

## Create a table

Import a JSON file into a MapR Database table. This command may take a minute to complete. `mapr importJSON -idField id -src /mapr/demo.mapr.com/user/mapr/data/flightdata2018.json -dst /user/mapr/flighttable -mapreduce false`{{execute}}

## CRUD Operations on the Shell

The ***mapr dbshell*** enables you to create and manipulate JSON tables in MapR-DB.

Open the MapR Database Shell utility. `mapr dbshell`{{execute}} 

Set the pretty print option. `jsonoptions --pretty true --withtags false`{{execute}}

Read the first 5 rows in the table. `find /user/mapr/flighttable --limit 5`{{execute}}

To learn more about the various commands, run help' or help <command> , for example `help insert`{{execute}}.

Query with condition to find flights originating from Atlanta `find /user/mapr/flighttable --where '{ "$eq" : {"src":"ATL"} }' --f id,src,dst,depdelay`{{execute}}

Query with condition to find flights originating from Atlanta that with departure delay greater than 60 minutes. `find /user/mapr/flighttable --where '{"$and":[{"$gt":{"depdelay":60}},{ "$like" : {"id":"ATL%"} }]}' --f id,depdelay`{{execute}}

Exit the shell. `exit`{{execute}}

### Run SQL with Apache Drill

Apache Drill is a distributed SQL engine integrated into the MapR Data Platform. Try it!

Open the Apache Drill shell:
`sqlline -u jdbc:drill:zk=localhost:5181 -n mapr -p mapr`{{execute}}

Query to find flights with id starting with LAX (originating from Los Angeles)  
<pre><code class="execute">select id, src, dst, depdelay from dfs.`/user/mapr/flighttable` where id like 'LAX%' order by depdelay desc limit 20;</code></pre>

Query to answer "Which departure hours have the most delayed flights" count flights with departure delay greater than 40 minutes by departure hour.
<pre><code class="execute">select crsdephour, count(depdelay) as countdelay from dfs.`/user/mapr/flighttable` where depdelay > 40 group by crsdephour order by crsdephour;</code></pre>

Query to answer "How many flights with a depature delay >40 minutes were there originating from Los Angeles when " count flights with departure delay greater than 40 minutes for src airport LAX.
<pre><code class="execute">select src, count(depdelay) as countdelayed from dfs.`/user/mapr/flighttable` where depdelay > 40 and src='LAX' group by src;</code></pre>

Exit the shell: `!quit`{{execute}}

