FROM ubuntu:latest
MAINTAINER Vitor/Sergio

# Install needed tools
RUN apt-get update; \
    apt-get install -y openssh-server python-software-properties wget default-jre vim nmap net-tools; \
    apt-get clean

#Download/Configuring hadoop
RUN mkdir /usr/local/hadoop && cd /usr/local/hadoop && wget http://ftp.unicamp.br/pub/apache/hadoop/core/current/hadoop-3.0.0-alpha4.tar.gz && tar -zxvf hadoop-3.0.0-alpha4.tar.gz && mv ./hadoop-3.0.0-alpha4/* ./ && rm -rf ./hadoop-3.0.0-alpha4.tar.gz

# Create hduser to run hadoop
RUN addgroup hadoop 
RUN adduser --ingroup hadoop --disabled-password --gecos "" hduser

#Configuring JAVA_HOME
RUN echo export JAVA_HOME=/usr/lib/jvm/default-java >> /home/hduser/.bashrc
RUN echo export JAVA_HOME=/usr/lib/jvm/default-java >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh
RUN mkdir -p /app/hadoop/tmp
RUN chown -R hduser /usr/local/hadoop

# Configuring passwordless ssh
RUN sed -i 's/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
RUN sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config 
USER hduser
RUN echo /home/hduser/.ssh/id_rsa | ssh-keygen -t rsa -P ""
RUN cat /home/hduser/.ssh/id_rsa.pub >> /home/hduser/.ssh/authorized_keys
RUN touch /home/hduser/.ssh/config
RUN echo StrictHostKeyChecking no >> /home/hduser/.ssh/config
RUN echo UserKnownHostsFile /dev/null >> /home/hduser/.ssh/config
USER root

#Other configs (AKA work arounds)
RUN echo /etc/init.d/ssh start >> /etc/bash.bashrc
RUN chown -R hduser /etc/ssh

# Hadoop start script
#ADD hadoop-start.sh ./hadoop-start.sh
#RUN mv ./hadoop-start.sh /usr/local/hadoop/bin/hadoop-start.sh

USER root
RUN /usr/local/hadoop/bin/hadoop namenode -format
USER hduser
RUN /usr/local/hadoop/sbin/./start-dfs.sh
USER root
#Start hadoop
#CMD ["/bin/bash", "/usr/local/hadoop/bin/hadoop-start.sh"]

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 10020 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
#Other ports
EXPOSE 49707 2122 22
