#!/bin/bash

# Bring the services up
function startServices {
  docker start nodemaster node2 node3
  sleep 5
  echo ">> Starting hdfs ..."
  docker exec -u hadoop -it nodemaster hadoop/sbin/start-dfs.sh
  sleep 5
  echo ">> Starting yarn ..."
  docker exec -u hadoop -d nodemaster hadoop/sbin/start-yarn.sh
  sleep 5
  echo ">> Starting Spark ..."
  docker exec -u hadoop -d nodemaster /home/hadoop/sparkcmd.sh start
  docker exec -u hadoop -d node2 /home/hadoop/sparkcmd.sh start
  docker exec -u hadoop -d node3 /home/hadoop/sparkcmd.sh start
  sleep 5
  docker exec -u hadoop -it nodemaster /home/hadoop/hadoop/bin/hadoop fs -mkdir -p .
  echo ">> Starting jupyter notebook server ..."
  masterIp=`docker inspect -f "{{ .NetworkSettings.Networks.sparknet.IPAddress }}" nodemaster`
  docker exec -u hadoop -d nodemaster jupyter notebook --ip=$masterIp --port=8888 --notebook-dir='/opt/spark-apps' --NotebookApp.token='' --NotebookApp.password=''

  show_info
}

function show_info {
  masterIp=`docker inspect -f "{{ .NetworkSettings.Networks.sparknet.IPAddress }}" nodemaster`
  echo "Hadoop info @ nodemaster: http://$masterIp:8088/cluster"
  echo "Spark info @ nodemaster:  http://$masterIp:8080/"
  echo "DFS Health @ nodemaster:  http://$masterIp:9870/dfshealth.html"
  echo "Jupyter notebook:  http://$masterIp:8888/?tree"
}

if [[ $1 = "start" ]]; then
  startServices
  exit
fi

if [[ $1 = "stop" ]]; then
  docker exec -u hadoop -d nodemaster /home/hadoop/sparkcmd.sh stop
  docker exec -u hadoop -d node2 /home/hadoop/sparkcmd.sh stop
  docker exec -u hadoop -d node3 /home/hadoop/sparkcmd.sh stop
  docker stop nodemaster node2 node3
  exit
fi

if [[ $1 = "deploy" ]]; then
  docker rm -f `docker ps -aq` # delete old containers
  docker network rm sparknet
  docker network create --driver bridge sparknet # create custom network

  # 3 nodes
  echo ">> Starting nodes master and worker nodes ..."
  docker run -d -p 8081:8081 -p 8080:8080 -p 8088:8088 -p 7077:7077 -p 9870:9870 -p 4040:4040 -p 8888:8888 --network sparknet --name nodemaster -h nodemaster -v `pwd`/spark-apps:/opt/spark-apps -it sparkbase
  docker run -dP --network sparknet --name node2 -it -h node2 -v `pwd`/spark-apps:/opt/spark-apps sparkbase
  docker run -dP --network sparknet --name node3 -it -h node3 -v `pwd`/spark-apps:/opt/spark-apps sparkbase

  # Format nodemaster
  echo ">> Formatting hdfs ..."
  docker exec -u hadoop -it nodemaster hadoop/bin/hdfs namenode -format
  startServices
  exit
fi

if [[ $1 = "info" ]]; then
  show_info
  exit
fi

echo "Usage: cluster.sh deploy|start|stop"
echo "                 deploy - create a new Docker network"
echo "                 start  - start the existing containers"
echo "                 stop   - stop the running containers" 
echo "                 info   - useful URLs" 
