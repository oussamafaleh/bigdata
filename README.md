# Ahmed Cheibani
# 1	Présentation 
Dans cette partie nous allons créer un cluster Hadoop avec des micro-services telsque : pyspark et Kafka decorizer, jupyter-notebook basé sur l’image Ubuntu 18.04.
Tous les containers sont basés sur une seule image docker qui sera créée par la suite from-scratch. 
Mais d'autres modifications seront apportées sur les containers à exécuter essentiellement celle de nœud- maître | esclave. En particulier, des fichiers des configurations vont être ajoutés avec des ports exposés pour l’accès à partir de machine host et assurent la communication entre les nœuds.
# 1.1	Objectifs du travail
Créé une seule image docker qui contient un système distribué et des micro-services avec docker compose pour exécuter un cluster Hadoop et des micro-services tel que pyspark zookeeper, Kafka, H.Base.
# 1.2	Configuration prérequis
Pour déployer l’environnement, nous aurons également besoin de Docker.
S’il n’ait pas encore installé, nous pouvons l'installer facilement en suivant les instructions sur la page d'accueil officielle de Docker.
https://docs.docker.com/install/
https://docs.docker.com/compose/install/
Vérification de la version de notre Docker Engine, Machine et Compose :
$ docker --version
$ docker-compose --version
$ docker-machine –version
Le client Docker doit également être installé sur tous les hôtes NodeManager sur lesquels les conteneurs Docker seront lancés et capables de démarrer les conteneurs docker.

# 1.3	Hiérarchie du répertoire de projet
 
Le répertoire hbase contient la configuration de la base de données NoSQl HBase.
Le répertoire script_config contient les scriptes d’exécutionde service et fiche de configuration principale.
Le répertoire spark_hadoop contient les fichiers de configuration de Hadoop HDFS et
 map-reduce spark
La racine contient les sources code pour docker et docker compose 
# 1.4	 Mini architecture du projet déployer
 
# 2	Building et déploiement
# 2.1	Création de l’image docker de base (Dockerfile)
L’image docker sera base sur le noyau doit être base sur un noyau Linux. 
Hadoop, Spark-hadoop, HBase et jupyter fonctionne très bien sur une variété de SE, nous 
utilisons Ubuntu 18.0.4
# 2.2	Installation des package requis
Divers logiciels sont requis pour Hadoop, notamment ssh et Java. Ceux-ci doivent être installés avant d'utiliser Hadoop.
# 2.3	Installation Hadoop, Spark, Kafka, Hbase et Jupyter
L'installation peut être effectuée en téléchargeant et en extrayant les packages binaires dans l’image Docker. Il existe de nombreux miroirs à partir desquels ces packages peut-être téléchargés.
# installer hadoop-2.7.7
RUN wget https://downloads.apache.org/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz && \
    tar -xzvf hadoop-2.7.7.tar.gz && \
    mv hadoop-2.7.7 /usr/local/hadoop && \
    rm hadoop-2.7.7.tar.gz

# install spark Hadooop
RUN wget https://downloads.apache.org/spark/spark-2.4.5/spark-2.4.5-bin-hadoop2.7.tgz && \
    tar -xzvf spark-2.4.5-bin-hadoop2.7.tgz && \
    mv spark-2.4.5-bin-hadoop2.7 /usr/local/spark && \
    rm spark-2.4.5-bin-hadoop2.7.tgz

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
# 2.4	Configuration SSH
Exécuter Hadoop en mode pseudo-distribué nécessite SSH.
Nous devrons également configurer des clés SSH, ce qui peut être fait comme ce qui est dans le fichier Dockerfile
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
COPY script_config/ssh_config /root/.ssh/config
# 2.5	Configuration Hadoop et HBase
Divers fichiers de configuration Hadoop doivent être créés ou mis à jour pour que Hadoop s'exécute correctement. Ces fichiers de configuration seront placés dans $HADOOP_HOME/etc/hadoop/ (voir repertoir spark_hadoop ).
# création de répertoire de config
RUN mkdir -p /jupyter_env && \
    mkdir -p /root/.jupyter && \
    mkdir -p ~/hdfs/namenode && \
    mkdir -p ~/hdfs/datanode && \
    mkdir -p /usr/local/hadoop/logs
# Copier les configuration de Hadoop
COPY spark_hadoop/hadoop-env.sh /usr/local/hadoop/etc/hadoop/
COPY spark_hadoop/spark-defaults.conf /usr/local/hadoop/conf/
COPY spark_hadoop/slaves /usr/local/hadoop/etc/hadoop/
COPY spark_hadoop/*.xml  /usr/local/hadoop/etc/hadoop/
# Copier les configurations de jupyter
COPY script_config/jupyter_notebook_config.py /root/.jupyter/
# copier la scripte d'exécution des services
COPY script_config/services.sh /root/
# Copier les configurations de HBASE 
COPY hbase/hbase-env.sh /usr/local/hbase/conf/
COPY hbase/hbase-site.xml /usr/local/hbase/conf/
# 2.6	Définition des variables d'environnement
Exportez les variables d’environnement toutes les variables nécessaires pour l’exécution.
ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin:/usr/local/spark/bin:/usr/local/kafka/bin:/usr/local/hbase/bin
Dans notre cas certain de nos variables est définit dans un fichier nommé docker-compose.env et sera par la suite injecté par docker compose dans les containers l’ors de l’exécution.
# 2.7	 Exposer les ports
Si nous souhaitons pouvoir communique entre les différents service et  afficher les différentes interfaces Web, nous exposons les ports associés dans notre fichier Dockerfile ou docker-compose.yml.
# 2.8	Déploiement de l'image Docker en local
À ce stade, toutes les packages doivent être en place et l’image peut être construite. Les étapes restantes consistent à formater le namenode, à exécuter services.sh qui va démarrer le serveur SSH et tous les autres services nécessaires.

# formatter les namenodes
RUN /usr/local/hadoop/bin/hdfs namenode -format
# injecter le script de démarrage des services 
ENTRYPOINT ["/root/services.sh"] 
# par défaut démarre tous les services dans le nœud-Maitre 
CMD ["AllService"]

Le script services sh est utilisé pour exécuter les services lors de lancements de l’image selon le mode suivant :
-	AllService
Utiliser pour un nœud Maistre exécuté tous les services telque , hadoop , spark-hadoop , kafka , zeekoper, hbase , jupyter
-	Juputer
Utiliser pour un nœud training exécuté spark-hadoop, jupyter
-	Slave
Utiliser pour les nœuds d’esclave du cluster

NB : dans le docker-compose si un container termine l’exécution de command ou service lors de démarrages il se quitte tous seuls (exit with code 0). Pour garder ces containers en marche on injecte à la fin de scripte ou avec CMDLe command « t/aille -/dev/null » ou dans le fichier docker compose.Y ml on met Tty=true 
#  2.8.1	Construction de l’image Docker 
L'exécution à partir du répertoire contenant notre Dockerfile et docker-compose.yml la commande :
 $ docker-compose build 
Créera notre image de docker locale

 
#  2.8.2	Déploiement du cluster
Une fois que nous avons l’image en locale sur notre machine nous allons créer un réseau virtual de type bridge avec  la commande :
$docker network create --driver=bridge hadoop
 
Puis démarrer le cluster à partir de du fichier de config docker-compose.yml avec la commande : 
$ docker-compose up -d –build
L’option -d est utilisé pour l'exécution en arrière-plan.
 
#  Vérification des containers en cours d’exécution
$docker container ls -a
$ docker ps 
Si tous fonctionnent bien nous allons trouver 3 containers exécuter.
 
Dans le fichier de config docker compose (docker-compose.yml) nous avons configurer un nœud maitre avec 2 nœuds esclaves. 

Accédez à http://localhost:8888 pour l’accès à jupyter
Accédez à http://localhost:50074 pour afficher l'état actuel du système Hadoop 
Accédez à http://localhost:8888 pour l’accès à l’interface utilisateur de Resource Manager WebUI
 

#  NB : pour la persistance des données générées et utilisées par les conteneurs Docker nous avons monté des volumes qui seront mappés entre les containers et la machine Host.

noeud-maitre:
    hostname: noeud-maitre
    container_name: noeud-maitre
    image: bigdata/spark-hadoop-kafka:latest
    build:
      context: .
      args:
        http_proxy: ${http_proxy}
        https_proxy: ${https_proxy}
    volumes:
      - /home/ahmed_cheibani/Spark:/jupyter_env
    command: AllService
    env_file:
      - docker-compose.env

Pour accès au container en mode interactive (exemple le conteneur nommé « nœud-maitre » en cours) taper la commande :
$ docker exec -it nœud-maitre bash
Pour enregistrer les poste-configuration de l’images on commit le container démarrer avec la commande :
$ docker commit ID-Container nom-de-limage:tag
Pour arrêter le cluster en toute sécurité et supprimer des conteneurs, nous utilisons la commande :
$ docker-compose down
# NB : Vous trouverez dans le répertoire racine l'ensemble du code source et des instructions détaillées avec des commentaires un chaque étape.

