#!/bin/bash
set -eo pipefail

export_env() 
{
echo "exportation des variables d'environmnet ..."

# set environment variables 
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 
export SPARK_HOME=/usr/local/spark
export KAFKA_HOME=/usr/local/kafka
# Configuration des variable d environment  jupyter 
export JUPYTER_PORT=8888
export JUPYTER_DIR=/mnt/jupyter_env 
export PYTHONPATH=$SPARK_HOME/python:$PYTHONPATH
export PYSPARK_DRIVER_PYTHON=jupyter
export PYSPARK_DRIVER_PYTHON_OPTS=notebook
export PYSPARK_PYTHON=python3
}
#Definure les fonction de chaque type de demarage
start_env1() 
{
    export_env
    
   	echo "starting environment de development  1  en cours ..."
}

start_all_services() 
{
   # export_env
    sh -c 'service ssh start'
    #demarage de kafka 
    echo -e "\n"
    echo ">>  zookeeper ..." 
    $KAFKA_HOME/bin/zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties &
    echo -e "\n"
     echo ">>  Kafka ..." 
    $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties &
    echo -e "\n"
    #Demarage de juputer 
    echo ">>  Hadoop Cluster  ..." 
    echo -e "\n"
    jupyter notebook --ip 0.0.0.0 --port $JUPYTER_PORT --notebook-dir ${JUPYTER_DIR} --no-browser --allow-root
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
    "env1")
        start_env1
        ;;
    "AllServicedev")
        start_all_services
        ;;
    *)
        exec $@
        ;;
esac
exit $?





