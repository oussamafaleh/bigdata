FROM ubuntu:18.04

MAINTAINER Takoua Abdellatif

WORKDIR /root

# installer openssh-server, openjdk et wget libghc-iproute-doc 
RUN apt-get update && apt-get install -y openssh-server openjdk-8-jdk wget vim nano python3-pip net-tools
#les dependencies de  PySpark
# apt-get install -y python3 python3-pip python3-numpy python3-matplotlib python3-scipy python3-pandas python3-simpy

#compatibiliter entre les versions de chaque outil installer
# installer hadoop-2.7.7
RUN wget https://downloads.apache.org/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz && \
    tar -xzvf hadoop-2.7.7.tar.gz && \
    mv hadoop-2.7.7 /usr/local/hadoop && \
    rm hadoop-2.7.7.tar.gz


# install spark Hadooop
RUN wget https://downloads.apache.org/spark/spark-2.4.7/spark-2.4.7-bin-hadoop2.7.tgz && \
    tar -xzvf spark-2.4.7-bin-hadoop2.7.tgz && \
    mv spark-2.4.7-bin-hadoop2.7 /usr/local/spark && \
    rm spark-2.4.7-bin-hadoop2.7.tgz

# install kafka 1.0.2
RUN wget https://archive.apache.org/dist/kafka/1.0.2/kafka_2.11-1.0.2.tgz && \
    tar -xzvf kafka_2.11-1.0.2.tgz && \
    mv kafka_2.11-1.0.2 /usr/local/kafka && \
    rm kafka_2.11-1.0.2.tgz

# install hbase 1.4.9
RUN wget https://archive.apache.org/dist/hbase/1.4.9/hbase-1.4.9-bin.tar.gz  && \ 
    tar -zxvf hbase-1.4.9-bin.tar.gz && \
    mv hbase-1.4.9 /usr/local/hbase && \
    rm hbase-1.4.9-bin.tar.gz

RUN pip3 install jupyter
RUN pip3 install pandas

#ajouter tous les variable dans l'environment de variable 
ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin:/usr/local/spark/bin:/usr/local/kafka/bin:/usr/local/hbase/bin 

#creation de repertoire de config
RUN mkdir -p /jupyter_env && \
    mkdir -p /root/.jupyter && \
    mkdir -p ~/hdfs/namenode && \
    mkdir -p ~/hdfs/datanode && \
    mkdir -p /usr/local/hadoop/logs && \
    mkdir -p /root/.ssh

#Copier les configuration de Hadoop
COPY spark_hadoop/hadoop-env.sh /usr/local/hadoop/etc/hadoop/
COPY spark_hadoop/spark-defaults.conf /usr/local/hadoop/conf/
COPY spark_hadoop/slaves /usr/local/hadoop/etc/hadoop/
COPY spark_hadoop/*.xml  /usr/local/hadoop/etc/hadoop/

#Copier les configuration de juputer
COPY jupyter/jupyter_notebook_config.py /root/.jupyter/

#config HBASE 
COPY hbase/hbase-env.sh /usr/local/hbase/conf/
COPY hbase/hbase-site.xml /usr/local/hbase/conf/

# La configuration SSH est requise pour 
#effectuer différentes opérations sur un cluster, telles que 
#le démarrage, l'arrêt, les opérations de shell de démon distribué

#RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys
COPY script_config/ssh_config /root/.ssh/config


#Crée des lien symbolique pour Python tous court
RUN ln -s /usr/lib/python3.6 /usr/lib/python   
RUN ln -s /usr/bin/python3.6 /usr/bin/python

#copier la scripte d'execution des services
COPY script_config/services.sh /root/
RUN chmod a+x /root/services.sh && \
    chmod a+x /usr/local/hadoop/sbin/start-dfs.sh && \
    chmod a+x /usr/local/hadoop/sbin/start-yarn.sh
RUN chmod 600 ~/.ssh/config
# formater les namenodes
RUN /usr/local/hadoop/bin/hdfs namenode -format
#injecter le script de demmarge des service 
ENTRYPOINT ["/root/services.sh"] 
#par defaut demarer tous les service
CMD ["AllService"]


