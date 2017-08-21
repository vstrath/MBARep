FROM ubuntu:latest
MAINTAINER Vitor/Sergio

# Install needed tools
USER root
RUN apt-get update; \
    apt-get install -y openssh-server python-software-properties wget default-jre vim nmap net-tools; \
    apt-get clean

# Create hduser
RUN addgroup hadoop && adduser --ingroup hadoop --disabled-password --gecos "" hduser

# Configuring passwordless ssh
RUN mkdir /var/run/sshd
RUN echo StrictHostKeyChecking no >> /etc/ssh/ssh_config
USER hduser
RUN echo /home/hduser/.ssh/id_rsa | ssh-keygen -t rsa -P ""
RUN cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys

#Download/Configuring hadoop
USER root
RUN mkdir /usr/local/hadoop && cd /usr/local/hadoop && wget http://ftp.unicamp.br/pub/apache/hadoop/core/current/hadoop-3.0.0-alpha4.tar.gz && tar -zxvf hadoop-3.0.0-alpha4.tar.gz && mv ./hadoop-3.0.0-alpha4/* ./ && rm -rf ./hadoop-3.0.0-alpha4
RUN echo export JAVA_HOME=/usr/lib/jvm/default-java >> /home/hduser/.bashrc
RUN echo export JAVA_HOME=/usr/lib/jvm/default-java >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh
#ADD update_bash /tmp/update_bash
#RUN cat /tmp/update_bash >> /home/hduser/.bashrc
#add hadoop-env.sh /tmp/hadoop-env.sh
#RUN mv -f /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop-env.sh
RUN mkdir -p /app/hadoop/tmp
RUN chown -R hduser /usr/local/hadoop

#Work Arounds (AKA Gambiarra)
RUN echo /etc/init.d/ssh start >> /etc/bash.bashrc
RUN echo export JAVA_HOME=/usr/lib/jvm/default-java >> /etc/profile && export PATH=$JAVA_HOME/bin:$PATH
RUN chown -R hduser /etc/ssh

#Starting Hadoop
CMD ssh localhost
CMD su hduser -c /usr/local/hadoop/bin/hadoop namenode -format
CMD su hduser -c /usr/local/hadoop/sbin/start-all.sh

USER root
# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 10020 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
#Other ports
EXPOSE 49707 2122 22
