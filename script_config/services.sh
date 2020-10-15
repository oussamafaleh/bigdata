#!/bin/bash
set -eo pipefail

export_env() 
{
echo "exportation des variables d'environmnet ..."

# set environment variables 
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 
export HADOOP_HOME=/usr/local/hadoop 
export SPARK_HOME=/usr/local/spark
export KAFKA_HOME=/usr/local/kafka
export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop
export LD_LIBRARY_PATH=/usr/local/hadoop/lib/native:$LD_LIBRARY_PATH
export HBASE_HOME=/usr/local/hbase
export CLASSPATH=$CLASSPATH:/usr/local/hbase/lib/*

# Configuration des variable d environment  jupyter 
export JUPYTER_PORT=8888
export JUPYTER_DIR=/jupyter_env 
export PYTHONPATH=$SPARK_HOME/python:$PYTHONPATH
export PYSPARK_DRIVER_PYTHON=jupyter
export PYSPARK_DRIVER_PYTHON_OPTS=notebook
export PYSPARK_PYTHON=python3
}
#Definure les fonction de chaque type de demarage
start_slave() 
{
    export_env
    #Tail -f pour la keep alive des conatainer slaves car docker compose 
    #exit zvec code 0 si le container termine l'execution
    sh -c 'service ssh start' && tail -f /dev/null
   	echo "preparation  des noeud slaves en cours ..."
}

start_full_Master() 
{

    sh -c 'service ssh start'
    #demarage de hadoop

    echo ">> execution de  hdfs ..." 
    echo -e "\n"
    $HADOOP_HOME/sbin/start-dfs.sh
    sleep 5
    echo ">> execution de  yarn ..." 
    echo -e "\n"
    $HADOOP_HOME/sbin/start-yarn.sh
    sleep 5
    echo -e "\n"

    #demarage de kafka 
    echo ">> execution de  Kfka maitre ..." 
    echo -e "\n"
    $KAFKA_HOME/bin/zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties &

    echo ">> execution de  kafka maitre ..." 
    echo -e "\n"
    $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties &

    echo -e "\n"

    #Demarage de juputer 
    echo ">>   Jupyter  ..." 
    echo -e "\n"
    jupyter notebook --ip 0.0.0.0 --port $JUPYTER_PORT --notebook-dir ${JUPYTER_DIR} --no-browser --allow-root &

     #Demarage de juputer 
    echo ">>  Hadoop Cluster  ..." 
    echo -e "\n"
    tail -f /dev/null
}


start_notebook_only()
 {
     export_env
     sh -c 'service ssh start'
     
    echo ">> execution de  jupyter notebook seulment ..." 
    echo -e "\n"
    mkdir -p ${JUPYTER_DIR}
    jupyter notebook --ip 0.0.0.0 --port $JUPYTER_PORT --notebook-dir ${JUPYTER_DIR} --no-browser --allow-root
    echo -e "\n"

}


case "$1" in
    "jupyter")
        start_notebook_only
        ;;
    "slave")
        start_slave
        ;;
    "AllService")
        start_full_Master
        ;;
    *)
        exec $@
        ;;
esac
exit $?





