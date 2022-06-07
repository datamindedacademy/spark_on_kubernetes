The goal of this exercise is for you to build a base Spark container image,
using Docker, and upload it to a container registry.

TASK 1: Build a container image
===============================

Navigate to $SPARK_HOME. Find the Dockerfile designed for kubernetes
deployments in $SPARK_HOME/kubernetes/dockerfiles/spark/.

Build the image using `docker build` where you specify at a minimum the path to
that file.

TASK 2: UPLOAD TO ECR
=====================

A container registry has been provided for you (instructor gives the address).
With your aws CLI configured, run the following so that `docker` can push
images directly into ECR.

```
ECR_REPO=${ECR_REPO:-getFromInstructor}
aws ecr get-login-password \
    --region eu-west-1 | \
    docker login \
    --username AWS \
    --password-stdin ${ECR_REPO%%/*}
```

Next, run `docker push`, passing it the name of the properly tagged image. For
private repositories, such as this one, the tag should be of the form
${ECR_REPO}:${IMAGE_TAG}. Using "latest" for the image tag is ambiguous. In
this case, use your initials or first name to make it unambiguous for the
entire group.
