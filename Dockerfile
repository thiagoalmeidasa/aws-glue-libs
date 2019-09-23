FROM openjdk:8

LABEL AUTHOR="Subramanya Vajiraya (subvj@amazon.com)"
ARG GLUE_VER
ARG SPARK_URL
ARG MAVEN_URL
ARG PYTHON_BIN

RUN apt-get update && apt-get install awscli zip git tar ${PYTHON_BIN} ${PYTHON_BIN}-pip -y

ADD ${MAVEN_URL} /tmp/maven.tar.gz
ADD ${SPARK_URL} /tmp/spark.tar.gz

RUN tar zxvf /tmp/maven.tar.gz -C ~/ && tar zxvf /tmp/spark.tar.gz -C ~/ && rm -rf /tmp/*
RUN echo 'export SPARK_HOME="$(ls -d /root/*spark*)"; export MAVEN_HOME="$(ls -d /root/*maven*)"; export PATH="$PATH:$MAVEN_HOME/bin:$SPARK_HOME/bin:/glue/bin"' >> ~/.bashrc
ENV PYSPARK_PYTHON "${PYTHON_BIN}"

WORKDIR /glue
ADD . /glue

RUN bash -l -c 'bash ~/.profile && bash /glue/bin/glue-setup.sh && sed -i -e "/^mvn/ s/^/#/" /glue/bin/glue-setup.sh; rm $(ls -d /glue/*jars*)/netty*'
CMD [ "bash", "-l", "-c", "gluepyspark" ]