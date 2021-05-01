# Cluster Spark  
***

## Setting up cluster

Create a 3 node Spark cluster over Hadoop. Including jupyter as default driver for pyspark shell.

1. Clone the repository

```bash 
git clone https://github.com/hhmida/gp-spark
```

2. Create the first docker image scalabase
```bash
cd scalabase
 ./build.sh
```

3. Create the second docker image sparkbase
```bash
cd ../spark
sudo ./build.sh
```

4. Deploying the cluster
```bash
cd ..
./cluster.sh deploy
```

**Options**

```bash
cluster.sh stop   # Stop the cluster
cluster.sh start  # Start the cluster
cluster.sh info   # Shows handy URLs of running cluster
cluster.sh deploy # Format the cluster and deploy images again
```

**Redeploying the cluster**

cluster.sh deploy # Format the cluster and deploy images again

This will remove everything from HDFS. The content of /opt/spark-apps will not be changed.

## Running worcount notebook

Putting data files on HDFS

- First, you need to connect to a node (here the nodemaster).
```bash
docker exec -it -u hadoop nodemaster bash
```
- Then copying the file on Hadoop file system:
```bash
cd /opt/spark-apps
hadoop fs -put shakespeare.txt
```
- Access to jupyter url in browser and open `wordcount.ipynb`. URL can be displayed using this command

```bash
./cluster.sh info
```

***
<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.