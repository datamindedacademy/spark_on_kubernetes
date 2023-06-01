FROM gitpod/workspace-base:2023-05-09-03-02-39

ARG KUBECTL_VERSION=v1.22.2

ENV TRIGGER_REBUILD 2
ENV DEBIAN_FRONTEND=noninteractive
ENV SPARK_LOCAL_IP=0.0.0.0
# needed for master

USER root
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk python3 python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    wget https://dlcdn.apache.org/spark/spark-3.2.1/spark-3.2.1-bin-hadoop3.2.tgz && \
    tar xzf spark-3*.tgz && \
    rm -rf spark-3*.tgz && \
    ln -s /home/gitpod/spark-3* /opt/spark && \
    export SPARK_HOME=/opt/spark && \
    echo "export SPARK_HOME=/opt/spark" >> /home/gitpod/.bashrc
# Install the AWS CLI and clean up tmp files
RUN wget https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -O ./awscliv2.zip && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf ./aws awscliv2.zip

# install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    sudo mv ./kubectl /usr/local/bin/kubectl && \

USER gitpod

RUN mkdir ~/.kube

# For vscode
EXPOSE 3000
# for spark
# EXPOSE 4040
