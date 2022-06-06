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

#RUN minikube --memory 4096 --cpus 3 start --driver=docker
# install kubectl

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    sudo mv ./kubectl /usr/local/bin/kubectl && \
    mkdir ~/.kube

# RUN set -x; cd "$(mktemp -d)" && \
#     OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
#     ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
#     curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz" && \
#     tar zxvf krew.tar.gz && \
#     KREW=./krew-"${OS}_${ARCH}" && \
#     "$KREW" install krew && \
#     echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> /home/gitpod/.bashrc

USER gitpod

# For vscode
EXPOSE 3000
# for spark
EXPOSE 4040
