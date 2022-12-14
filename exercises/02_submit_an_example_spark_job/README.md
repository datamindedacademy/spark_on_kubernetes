The goal of this exercise is to run an example Spark job (an approximation of
the number Pi by using a Monte Carlo simulation) on the kubernetes cluster. You
will need to retrieve the details you need to do so.

Additionally, we'll go over a few of the configuration settings.

TASK
====

Complete the following script, then run the spark-submit command.

```
DRIVER_POD_NAME=<CHOOSE SOMETHING THAT DISTINGUISHES YOU FROM YOUR FELLOW PARTICIPANTS, LIKE YOUR NAME>
KUBERNETES_MASTER=$(kubectl config view --output=jsonpath='{.clusters[].cluster.server}')
ECR_REPO=<GET FROM INSTRUCTOR>
IMAGE_TAG=<THINK>

SVC_ACCOUNT_NAME=${SVC_ACCOUNT_NAME:-driver-sa}
NAMESPACE=${NAMESPACE:-spark-jobs}

pushd $SPARK_HOME
./bin/spark-submit \
    --master k8s://$KUBERNETES_MASTER  \
    --deploy-mode cluster \
    --name spark-pi \
    --class org.apache.spark.examples.SparkPi \
    --conf spark.kubernetes.namespace=${NAMESPACE} \
    --conf spark.kubernetes.driver.pod.name=${DRIVER_POD_NAME} \
    --conf spark.kubernetes.container.image=${ECR_REPO}:${IMAGE_TAG} \
    --conf spark.kubernetes.authenticate.driver.serviceAccountName=${SVC_ACCOUNT_NAME} \
    --conf spark.kubernetes.executor.request.cores=500m \
    --conf spark.kubernetes.executor.limit.cores=500m \
    --conf spark.executor.instances=1 \
    --conf spark.executor.cores=1 \
    local:///opt/spark/$(find . -name '*examples*jar')

popd
```

TASK
====

Analyze the logs when the job has completed. To do so, run `kubectl logs <THE
SPARK DRIVER POD NAME YOU CHOSE EARLIER> --namespace <NAMESPACE IN WHICH THE
PODS WERE DEPLOYED>`.

1. To verify that you got to this point correctly, find out how many digits behind the comma the number Pi is logged? 
2. Unrelated to K8s, and even to Spark, but interesting nevertheless: why do most people read a different value of Pi?
3. What is the advantage to interpolating the output of `find` in the `spark-submit` command?