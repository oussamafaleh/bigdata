echo -e "\n"
echo ">>  ******* Debut  ******  " 
echo -e "\n"


echo ">> suprimer les dossier s'ils existent  ..." 
echo -e "\n"
hadoop fs -rm -r  input
hadoop fs -rm -r  output

echo -e "\n"
echo ">> creer dossier input dans hadoop hdfs  ..." 
echo -e "\n"
hadoop fs -mkdir -p input

echo -e "\n"
echo ">> lister les contenue de /user/root " "   ..." 
echo -e "\n"
hdfs dfs -ls /user/root

echo -e "\n"
echo ">>  copier ficher texte dans le dossier input et afficher leur contenue via hadoop fs   ..." 
echo -e "\n"
hadoop fs -put /jupyter_env/file1.txt input

echo -e "\n"
echo ">>  lister contenuer input et verifier si fichier txt existe    ..." 
echo -e "\n"
hadoop fs -ls input

echo -e "\n"
echo ">>  afficher le contenue du fichier    ..." 
echo -e "\n"
hadoop fs -tail input/file1.txt

echo -e "\n"
echo ">>  verfier et tester les fichier mapper.py et reduce.py " 
echo -e "\n"


echo -e "\n"
echo ">>  executer Hadoop MapReduce Python   " 
echo ">>  l'entrer : input -- Sortie : output    " 
echo -e "\n"

hadoop jar $HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-2.7.7.jar \
-file /jupyter_env/mapreduce/mapper.py    -mapper /jupyter_env/mapreduce/mapper.py \
-file /jupyter_env/mapreduce/reducer.py   -reducer /jupyter_env/mapreduce/reducer.py \
-input input/* -output output

echo -e "\n"
echo ">>  afficher les resultat du programme  " 
echo -e "\n"
hadoop fs -tail output/part-00000 


echo -e "\n"
echo ">>  ******* Fin ******  " 
echo -e "\n"
