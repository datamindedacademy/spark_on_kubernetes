The goal of this exercise is to explain that the service account name
you use in the call to Spark-submit is linked with a role in the k8s
cluster and the permissions of that role determine what you can do. In
particular, the Spark driver needs to be able to request new pods.

TASK
====

Analyze the error message. Resolve the situation by granting "edit" permissions to the role.
