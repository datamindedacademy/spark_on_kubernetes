#FROM gitpod/workspace-python:2022-02-01-06-13-37
# FROM gitpod/workspace-full
FROM gitpod/workspace-base:latest

ARG KUBECTL_VERSION=v1.22.2

ENV TRIGGER_REBUILD 2
ENV DEBIAN_FRONTEND=noninteractive
ENV SPARK_LOCAL_IP=0.0.0.0
# needed for master

USER root

RUN apt-get update && \
    apt-get install -y openjdk-8-jdk python3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    wget https://archive.apache.org/dist/spark/spark-3.3.0/spark-3.3.0-bin-hadoop3.tgz  && \
    tar xzf spark-3*.tgz && \
    rm -rf spark-3*.tgz && \
    ln -s /home/gitpod/spark-3* /opt/spark && \
    export SPARK_HOME=/opt/spark && \
    echo "export SPARK_HOME=/opt/spark" >> /home/gitpod/.bashrc

RUN wget https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -O ./awscliv2.zip && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf ./aws awscliv2.zip

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    sudo mv ./kubectl /usr/local/bin/kubectl && \
    mkdir ~/.kube

USER gitpod

# For vscode
EXPOSE 3000
# for spark
EXPOSE 4040
