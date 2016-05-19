FROM acntech/jdk:1.8.0_92
MAINTAINER Thomas Johansen "thomas.johansen@accenture.com"


ENV HADOOP_HOME /opt/hadoop/default
ENV HADOOP_MAPRED_HOME $HADOOP_HOME
ENV HADOOP_COMMON_HOME $HADOOP_HOME
ENV HADOOP_HDFS_HOME $HADOOP_HOME
ENV HADOOP_INSTALL $HADOOP_HOME
ENV HADOOP_COMMON_LIB_NATIVE_DIR $HADOOP_HOME/lib/native
ENV YARN_HOME $HADOOP_HOME
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin


RUN apt-get -y update && apt-get -y install ssh vim

RUN wget --no-cookies --no-check-certificate "https://dist.apache.org/repos/dist/release/hadoop/common/hadoop-2.7.2/hadoop-2.7.2.tar.gz" -O /tmp/hadoop.tar.gz
RUN wget --no-cookies --no-check-certificate "https://dist.apache.org/repos/dist/release/hadoop/common/hadoop-2.7.2/hadoop-2.7.2.tar.gz.asc" -O /tmp/hadoop.tar.gz.asc
RUN wget --no-cookies --no-check-certificate "https://dist.apache.org/repos/dist/release/hadoop/common/KEYS" -O /tmp/hadoop.KEYS
RUN gpg --import /tmp/hadoop.KEYS && gpg --verify /tmp/hadoop.tar.gz.asc /tmp/hadoop.tar.gz
RUN mkdir /opt/hadoop && tar -xzvf /tmp/hadoop.tar.gz -C /opt/hadoop/ && ln -s /opt/hadoop/hadoop-2.7.2/ /opt/hadoop/default && rm -f /tmp/hadoop.*


RUN update-rc.d ssh defaults

RUN ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 0600 ~/.ssh/authorized_keys


COPY var/* /opt/hadoop/default/etc/hadoop/


RUN mkdir -p $HOME/hadoopinfra/hdfs/{namenode,datanode}
RUN hdfs namenode -format


EXPOSE 22 9000 50070


CMD service ssh start && /bin/bash