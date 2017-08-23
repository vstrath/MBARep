#!/bin/bash

su /usr/sbin/sshd
su hduser -c /usr/local/hadoop/bin/hadoop namenode -format
su hduser -c /usr/local/hadoop/sbin/./start-dfs.sh
#tail -f $HADOOP_HOME/logs/*
