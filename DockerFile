FROM ubuntu:latest
MAINTAINER Vitor/Sergio

USER root

# Install needed tools
RUN apt-get update; \
    apt-get install -y openssh-server python-software-properties wget default-jre; \
    apt-get clean

# Configuring passwordless ssh
RUN rm /etc/ssh/ssh_host_dsa_key && ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN rm /etc/ssh/ssh_host_rsa_key && ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -P "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
RUN mkdir /var/run/sshd

#Disabling IPV6 (Known issue)
#TEST LATER

#Download hadoop
RUN mkdir /usr/local/hadoop && cd /usr/local/hadoop && wget http://ftp.unicamp.br/pub/apache/hadoop/core/current/hadoop-3.0.0-alpha4.tar.gz && tar -zxvf hadoop-3.0.0-alpha4.tar.gz && mv ./hadoop-3.0.0-alpha4/* ./ && rm -rf ./hadoop-3.0.0-alpha4

#Update Bashrc
ADD update_bash $HOME/.bashrc

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
