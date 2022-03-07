#FROM gitpod/workspace-python:2022-02-01-06-13-37
# FROM gitpod/workspace-full
FROM ghcr.io/szab100/gitpod-k3s-qemu

ENV TRIGGER_REBUILD 2
ENV DEBIAN_FRONTEND=noninteractive
ENV SPARK_LOCAL_IP=0.0.0.0
# needed for master

USER root
# Install apt packages and clean up cached files
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk python3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    wget https://dlcdn.apache.org/spark/spark-3.2.1/spark-3.2.1-bin-hadoop3.2.tgz && \
    tar xzf spark-3*.tgz && \
    rm -rf spark-3*.tgz
# Install the AWS CLI and clean up tmp files
RUN wget https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -O ./awscliv2.zip && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf ./aws awscliv2.zip

#RUN minikube --memory 4096 --cpus 3 start --driver=docker

USER gitpod

# For vscode
EXPOSE 3000
# for spark
EXPOSE 4040
