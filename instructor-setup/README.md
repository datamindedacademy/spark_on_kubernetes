# Instructor setup

As the instructor, you should set up some cloud resources (EKS, ECR, IAM user)
using terraform and configure the EKS cluster. While you can configure a k8s
cluster using Terraform, here the classical approach using kubectl is chosen,
mainly for learning purposes of the instructor.

The exercises that students should run require between 2 and 4h, depending on
their level. If things go well, you can get them to slim down a Docker image by
e.g. removing some jars from the base Docker image or to create a Spark
application from scratch, write a Dockerfile for it and submit that.

## Create an EKS cluster with dashboard and ECR resource

```bash
terraform init

# Note: when a default tag has a derived value (e.g. using the
# timestamp() function, it will fail. See
# https://github.com/hashicorp/terraform-provider-aws/issues/19583#issuecomment-1136999264

terraform apply  # takes about 11m. 
# You might need to run this twice, see issue 19583.

```

The Terraform configuration files to provision an EKS cluster on AWS were
obtained from the companion repo to the [Provision an EKS Cluster learn
guide](https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster)
and modified to 

1. take advantage of the default_tags feature in the AWS provider (since 3.38),
2. change the network settings of the VPC,
3. use the newer t3 instance types, which are marginally cheaper.
4. include the provisioning of an ECR resource.
5. use a newer version of Kubernetes on EKS.


Next, follow the steps to [update the kubectl config file][update config]
(which likely won't be needed if you use a newer version of the eks module
instead of the one referenced by the tutorial), since the output kubectl_config
contains a few older settings and `kubectl` will error out if you use it.

```
aws eks \
  --region $(terraform output -raw region) \
  update-kubeconfig \
  --name $(terraform output -raw cluster_name)
```

Then, deploy the Kubernetes metric server and the dashboard, as mentioned in
the tutorial:

```
wget -O v0.3.6.tar.gz https://codeload.github.com/kubernetes-sigs/metrics-server/tar.gz/v0.3.6 && tar -xzf v0.3.6.tar.gz
kubectl apply -f metrics-server-0.3.6/deploy/1.8+/
kubectl get deployment metrics-server -n kube-system
# Should show 1/1 READY deployment.

# Updated from the kubernetes docs, not the tutorial.
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml
```

The last step creates the "kubernetes-dashboard" namespace as part of the
installation of the service. 

The tutorial goes on to allow the "service-controller" account limited access
to the dashboard, but you can [create a user] that has full access to it:

```
kubectl apply -f dashboard-adminuser.yaml

# TODO: make this view-setting only.
kubectl apply -f dashboard-clusterrolebinding.yaml

# Get the bearer token
kubectl -n kubernetes-dashboard create token admin-user
```

Finally, get [access to the dashboard] using a proxy:

```
kubectl proxy
```

Navigate to the [dashboard].

## Grant kubectl admin permissions to students, to run spark-submit

Without more changes to the EKS cluster, participants will encounter an unauthorized server error upon connecting to the Amazon EKS API server. This [recent change] requests the creator of the EKS cluster (you, running `terraform apply` using your SSO credentials) to still run:

```
kubectl edit configmap aws-auth --namespace kube-system
```

And modify the part under `mapUsers` (only the `mapUsers` section, since in this workshop we configure participants access to AWS using a privilege-limited user account, not a role), to reflect:

```
mapUsers: |
  - userarn: arn:aws:iam::XXXXXXXXXXXX:user/testuser
    username: testuser
    groups:
      - system:masters
```
with the userarn being the one displayed by students in gitpod after running

```
aws sts get-caller-identity
```

After applying that change as the EKS admin, you'll need to ask students to run 

```
aws eks update-kubeconfig --name <eks-cluster-name> --region <aws-region>
```

After that change, they should be able to run `spark-submit` but also 

```
kubectl get svc
```

Once students ran spark-submit and saw in the streamed logs that the job ran
successfully, they can get the actual logs from the driver pod using:

```
kubectl logs ${DRIVER_POD_NAME} --namespace ${NAMESPACE}
```

Do not forget to deleter the driver pod, when you're done or want to run another job.
TODO: set auto-delete after 5 minutes

```
kubectl delete pod ${DRIVER_POD_NAME} --namespace ${NAMESPACE}
```

[recent change]: https://aws.amazon.com/premiumsupport/knowledge-center/eks-api-server-unauthorized-error/#You.27re_not_the_cluster_creator
[update_config]: https://learn.hashicorp.com/tutorials/terraform/eks#configure-kubectl
[create a user]: https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
[dashboard]: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/.
[access to the dashboard]: https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/#accessing-the-dashboard-ui
