FROM ubuntu:latest
MAINTAINER Vitor/Sergio

# Install needed tools
USER root
RUN apt-get update; \
    apt-get install -y openssh-server python-software-properties wget default-jre vim nmap net-tools; \
    apt-get clean

#Download/Configuring hadoop
RUN mkdir /usr/local/hadoop && cd /usr/local/hadoop && wget http://ftp.unicamp.br/pub/apache/hadoop/core/current/hadoop-3.0.0-alpha4.tar.gz && tar -zxvf hadoop-3.0.0-alpha4.tar.gz && mv ./hadoop-3.0.0-alpha4/* ./ && rm -rf ./hadoop-3.0.0-alpha4.tar.gz

# Create hduser to run hadoop
RUN addgroup hadoop && adduser --ingroup hadoop --disabled-password --gecos "" hduser

#Configuring JAVA_HOME
RUN echo export JAVA_HOME=/usr/lib/jvm/default-java >> /home/hduser/.bashrc && echo export JAVA_HOME=/usr/lib/jvm/default-java >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh && mkdir -p /app/hadoop/tmp && chown -R hduser /usr/local/hadoop

# Configuring passwordless ssh
RUN apt-get install gpw && gpw 1 10 >> /etc/hostname
RUN sed -i 's/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
RUN sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
USER hduser
RUN echo /home/hduser/.ssh/id_rsa | ssh-keygen -t rsa -P "" && cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
RUN touch ~/.ssh/config && echo Host * >> ~/.ssh/config && echo StrictHostKeyChecking no >> ~/.ssh/config 


#Other configs (AKA work arounds)
USER root
RUN echo /etc/init.d/ssh start >> /etc/bash.bashrc
#RUN echo export JAVA_HOME=/usr/lib/jvm/default-java >> /etc/profile && export PATH=$JAVA_HOME/bin:$PATH
RUN chown -R hduser /etc/ssh

#Starting Hadoop
USER hduser
CMD su hduser -c /usr/local/hadoop/bin/hadoop namenode -format
CMD su hduser -c /usr/local/hadoop/sbin/./start-dfs.sh

USER root
# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 10020 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
#Other ports
EXPOSE 49707 2122 22
