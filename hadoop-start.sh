#!/bin/bash

/usr/local/hadoop/bin/hadoop namenode -format
/usr/local/hadoop/sbin/./start-dfs.sh
#tail -f $HADOOP_HOME/logs/*
