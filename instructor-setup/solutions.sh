#!/usr/bin/env bash

set -euxo pipefail
IFS=$'\n\t'  # prevents many common mistakes



#####################################################
# Part 1: create and push a containerized application
#####################################################
IMAGE_TAG=3.2.0
# Note: this repo will be destroyed after today's class.
ECR_REPO=338791806049.dkr.ecr.eu-west-1.amazonaws.com/spark-on-k8s

# The instructor gives you the AWS key pair with which you can configure access
# to AWS.

# Afterwards, you can authenticate the docker CLI to AWS ECR.
aws ecr get-login-password \
    --region eu-west-1 | \
    docker login \
    --username AWS \
    --password-stdin ${ECR_REPO%%/*}

cd $SPARK_HOME

# Create a default Scala flavored Spark image
docker build \
    --tag spark:${IMAGE_TAG} \
    --file kubernetes/dockerfiles/spark/Dockerfile \
    .

# Create a PySpark flavoured Spark image
docker build \
    --build-arg base_img=spark:${IMAGE_TAG} \
    --tag pyspark:${IMAGE_TAG} \
    --file kubernetes/dockerfiles/spark/bindings/python/Dockerfile \
    .

# Test your successful build with
# docker run -it pyspark:3.2.0 /opt/spark/bin/pyspark
# That will open a pyspark shell _inside_ the container,
# where you can run, e.g., 
# spark.range(10).show()

# Retag the Docker image so that you can upload it to the private repo.
docker tag \
    pyspark:${IMAGE_TAG} \
    ${ECR_REPO}:${IMAGE_TAG}
# In case you didn't tag while building, you
# can use the IMAGE ID as the "origin" in
# docker tag $origin $destination

# The previous command is needed as otherwise the next command won't know where
# to push the docker image to.
docker push ${ECR_REPO}:${IMAGE_TAG}

#####################################################
# Part 2: submit a Spark application to EKS
#####################################################

DRIVER_POD_NAME=spark-pi-driver
# Note: this kubernetes master link won't work after today's class, since we destroy the EKS cluster.
KUBERNETES_MASTER=https://4B536F8E0D392EB5B089ABDC7FFCB0B1.gr7.eu-west-1.eks.amazonaws.com
# This namespace was created for you
NAMESPACE=${NAMESPACE:-spark-jobs}
# Same with this repo: this will be destroyed.
ECR_REPO=338791806049.dkr.ecr.eu-west-1.amazonaws.com/spark-on-k8s
# Use the tag that you pushed to ECR.
IMAGE_TAG=${IMAGE_TAG:-3.2.0}
# This service account was created for you and had the right permissions.
SVC_ACCOUNT_NAME=${SVC_ACCOUNT_NAME:-driver-sa}

# To submit a program, one could use the spark-submit application that comes
# with the Spark download. It is in the $SPARK_HOME folder.
pushd $SPARK_HOME
./bin/spark-submit     \
    --master k8s://$KUBERNETES_MASTER     \
    --deploy-mode cluster     \
    --name spark-pi     \
    --class org.apache.spark.examples.SparkPi     \
    --conf spark.kubernetes.namespace=${NAMESPACE}     \
    --conf spark.kubernetes.driver.pod.name=${DRIVER_POD_NAME}     \
    --conf spark.kubernetes.container.image=${ECR_REPO}:${IMAGE_TAG}     \
    --conf spark.kubernetes.authenticate.driver.serviceAccountName=${SVC_ACCOUNT_NAME}      \
    --conf spark.kubernetes.executor.request.cores=500m     \
    --conf spark.kubernetes.executor.limit.cores=500m     \
    --conf spark.executor.instances=1     \
    --conf spark.executor.cores=1 local:///opt/spark/$(find . -name '*examples*jar')
popd

# Note the many configuration options. Some relate specifically to running on a
# Kubernetes cluster, rather than, e.g. a YARN cluster (like AWS EMR). Others are
# related to the actual Spark process. In the previous, you instruct the
# Kubernetes cluster to run the SparkPi application, which is in the examples jar
# file that is packaged into your Docker image, with just one executor.
