FROM acntech/jdk:1.8.0_92
MAINTAINER Thomas Johansen "thomas.johansen@accenture.com"


ENV HADOOP_HOME /opt/hadoop/default
ENV HADOOP_CONF_DIR /etc/hadoop/
ENV HADOOP_LOG_DIR /var/log/hadoop
ENV HADOOP_PID_DIR /var/run/hadoop
ENV HADOOP_INSTALL $HADOOP_HOME
ENV HADOOP_MAPRED_HOME $HADOOP_HOME
ENV HADOOP_COMMON_HOME $HADOOP_HOME
ENV HADOOP_HDFS_HOME $HADOOP_HOME
ENV HADOOP_COMMON_LIB_NATIVE_DIR $HADOOP_HOME/lib/native
ENV YARN_HOME $HADOOP_HOME
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin


RUN apt-get -y update && apt-get -y install sudo ssh vim net-tools

RUN wget --no-cookies --no-check-certificate "https://dist.apache.org/repos/dist/release/hadoop/common/hadoop-2.7.2/hadoop-2.7.2.tar.gz" -O /tmp/hadoop.tar.gz
RUN wget --no-cookies --no-check-certificate "https://dist.apache.org/repos/dist/release/hadoop/common/hadoop-2.7.2/hadoop-2.7.2.tar.gz.asc" -O /tmp/hadoop.tar.gz.asc
RUN wget --no-cookies --no-check-certificate "https://dist.apache.org/repos/dist/release/hadoop/common/KEYS" -O /tmp/hadoop.KEYS
RUN gpg --import /tmp/hadoop.KEYS && gpg --verify /tmp/hadoop.tar.gz.asc /tmp/hadoop.tar.gz
RUN mkdir /opt/hadoop && tar -xzvf /tmp/hadoop.tar.gz -C /opt/hadoop/ && ln -s /opt/hadoop/hadoop-2.7.2/ /opt/hadoop/default && rm -f /tmp/hadoop.*


RUN cp -r $HADOOP_HOME/etc/hadoop/ /etc/ && mkdir -p /var/log/hadoop && mkdir -p /var/run/hadoop

RUN useradd --create-home --user-group hadoop
RUN echo "root:welcome1" | chpasswd && echo "hadoop:welcome1" | chpasswd
RUN chown -R hadoop:hadoop /opt/hadoop /var/log/hadoop /var/run/hadoop
RUN echo "hadoop ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers


COPY etc/* /etc/hadoop/


USER hadoop


RUN ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 0600 ~/.ssh/authorized_keys
RUN ssh -o "StrictHostKeyChecking no" hadoop@localhost
RUN ssh -o "StrictHostKeyChecking no" hadoop@0.0.0.0

RUN mkdir -p ~/hadoopinfra/hdfs/{namenode,datanode}

RUN hdfs namenode -format


EXPOSE 22 8088 9000 50010 50020 50070 50090 


CMD sudo service ssh start && /bin/bash