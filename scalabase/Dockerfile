from openjdk:8

MAINTAINER Hmida Hmida <hhmida@gmail.com>

USER root
EXPOSE 22/tcp
EXPOSE 22/udp

RUN apt-get update && \
    apt-get install -y --no-install-recommends openssh-server vim

WORKDIR /tmp
RUN wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py && pip install numpy deap jupyter pyspark
RUN wget https://downloads.lightbend.com/scala/2.12.5/scala-2.12.5.tgz && \
    tar xzf scala-2.12.5.tgz && \
    mv scala-2.12.5 /usr/share/scala && \
    ln -s /usr/share/scala/bin/* /usr/bin && \ 
    rm scala-2.12.5.tgz && \
\
    echo "PubkeyAuthentication yes" >> /etc/ssh/ssh_config && \
    echo "Host *" >> /etc/ssh/ssh_config

CMD service ssh start && sleep infinity
