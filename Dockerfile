FROM ubuntu:latest
MAINTAINER Vitor/Sergio

# Install needed tools
USER root
RUN apt-get update; \
    apt-get install -y openssh-server python-software-properties wget default-jre; \
    apt-get clean

#ENV Variables
ENV HADOOP_PREFIX /usr/local/hadoop

#Create hduser
addgroup hadoop
adduser --ingroup hadoop hduser

# Configuring passwordless ssh
USER hduser
RUN echo /home/hduser/.ssh/id_rsa | ssh-keygen -t rsa -P "" && mkdir /var/run/sshd

#Download hadoop
USER root
RUN mkdir $HADOOP_PREFIX && cd $HADOOP_PREFIX && wget http://ftp.unicamp.br/pub/apache/hadoop/core/current/hadoop-3.0.0-alpha4.tar.gz && tar -zxvf hadoop-3.0.0-alpha4.tar.gz && mv ./hadoop-3.0.0-alpha4/* ./ && rm -rf ./hadoop-3.0.0-alpha4

#Configure Hadoop
ADD update_bash /tmp/update_bash
RUN cat /tmp/update_bash >> $HOME/.bashrc
RUN echo export JAVA_HOME=/usr/lib/jvm/default-java >> $HADOOP_PREFIX/etc/hadoop-env.sh
RUN mkdir -p /app/hadoop/tmp

#Work Arounds (AKA Gambiarra)
RUN echo /usr/sbin/sshd >> /etc/bash.bashrc

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 10020 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
#Other ports
EXPOSE 49707 2122 22
