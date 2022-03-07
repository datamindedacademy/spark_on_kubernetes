#!/usr/bin/env bash

set -xeuo pipefail
IFS=$'\n\t'  # prevents many common mistakes

NAMESPACE=spark-jobs
SVC_ACCOUNT_NAME=driver-sa
DOCKER_IMAGE_TAG=spark:latest
DRIVER_POD_NAME=spark-pi-driver

#================================================================================
# Cluster setup
#================================================================================
minikube --memory 4096 --cpus 3 start
KUBERNETES_MASTER=$(kubectl config view --output=jsonpath='{.clusters[].cluster.server}')

# Apply best practice: use namespaces to organize and logically isolate services in different namespaces.
kubectl apply -f ../k8s/driver-sa-rbac.yaml
# There's smt to be said about both approaches: the 'apply' option is
# declarative, but it does not allow reusing references in YAML (YAML
# limitation, use frameworks to overcome). The 'create' option is imperative,
# but allows reusing variables. You'll need to add error handling here in case
# you re-run.

#================================================================================
# Build Docker image
#================================================================================
cd $SPARK_HOME
eval $(minikube docker-env)
docker build \
    --tag ${DOCKER_IMAGE_TAG} \
    --file kubernetes/dockerfiles/spark/Dockerfile .


#================================================================================
# Submit a job
#================================================================================
./bin/spark-submit \
    --master k8s://$KUBERNETES_MASTER \
    --deploy-mode cluster \
    --name spark-pi \
    --class org.apache.spark.examples.SparkPi \
    --conf spark.executor.instances=2 \
    --conf spark.kubernetes.namespace=${NAMESPACE} \
    --conf spark.kubernetes.driver.pod.name=${DRIVER_POD_NAME} \
    --conf spark.kubernetes.container.image=${DOCKER_IMAGE_TAG} \
    --conf spark.kubernetes.authenticate.driver.serviceAccountName=${SVC_ACCOUNT_NAME} \
    local:///opt/spark/$(find . -name '*examples*jar')

kubectl logs ${DRIVER_POD_NAME} --namespace ${NAMESPACE}

kubectl delete pod ${DRIVER_POD_NAME} --namespace ${NAMESPACE}
