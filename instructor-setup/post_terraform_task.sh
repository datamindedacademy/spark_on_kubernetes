#!/usr/bin/env bash

set -euxo pipefail
IFS=$'\n\t'  # prevents many common mistakes

NAMESPACE=spark-jobs
SVC_ACCOUNT_NAME=driver-sa

kubectl create namespace ${NAMESPACE}
kubectl create serviceaccount ${SVC_ACCOUNT_NAME} --namespace ${NAMESPACE}
# The "edit" clusterrole was once part of an exercise more geared towards administrators.
# Without it (the option was "read", IIRC), users got an error, indicating insufficient
# permissions of the driver service account (SVC_ACCOUNT_NAME).
kubectl create clusterrolebinding spark-role-binding \
    --clusterrole=edit \
    --serviceaccount=${NAMESPACE}:${SVC_ACCOUNT_NAME} \
    --namespace=${NAMESPACE}


