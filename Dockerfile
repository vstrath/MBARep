FROM ubuntu

RUN apt-get update && apt-get install -y openssh-server python-software-properties wget default-jre vim 

#Download/Configuring hadoop
RUN mkdir /usr/local/hadoop && cd /usr/local/hadoop && wget http://ftp.unicamp.br/pub/apache/hadoop/core/current/hadoop-3.0.0-alpha4.tar.gz && tar -zxvf hadoop-3.0.0-alpha4.tar.gz && mv ./hadoop-3.0.0-alpha4/* ./ && rm -rf ./hadoop-3.0.0-alpha4.tar.gz && addgroup hadoop && adduser --ingroup hadoop --disabled-password --gecos "" hduser && echo export JAVA_HOME=/usr/lib/jvm/default-java >> /home/hduser/.bashrc && echo export JAVA_HOME=/usr/lib/jvm/default-java >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh && mkdir -p /app/hadoop/tmp && chown -R hduser /usr/local/hadoop

#Adding hadoop conf files
ADD core-site.xml /usr/local/hadoop/etc/hadoop/core-site.xml
ADD hdfs-site.xml /usr/local/hadoop/etc/hadoop/hdfs-site.xml 
ADD mapred-site.xml /usr/local/hadoop/etc/hadoop/mapred-site.xml

#SSH
RUN echo "yes" | ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && echo "yes" | ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && mkdir /var/run/sshd && echo UserKnownHostsFile=/dev/null >> /etc/ssh/ssh_config && echo StrictHostKeyChecking=no >> /etc/ssh/ssh_config
USER hduser
RUN ssh-keygen -q -N "" -t rsa -f /home/hduser/.ssh/id_rsa && cp /home/hduser/.ssh/id_rsa.pub /home/hduser/.ssh/authorized_keys
USER root


# Exposings hadoop ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000 10020 19888 8030 8031 8032 8033 8040 8042 8088 49707 2122 22
# Exposing ssh port
EXPOSE 22

ENTRYPOINT /usr/sbin/sshd
#CMD ["/usr/sbin/sshd", "-D"]
ENTRYPOINT su hduser -c /usr/local/hadoop/bin/hadoop namenode -format
ENTRYPOINT su hduser -c /usr/local/hadoop/sbin/./start-all.sh

