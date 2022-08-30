variable "keybase_user" {
  description = <<-EOM
    Enter the keybase id of a person to encrypt the AWS IAM secret access key.
    Note that you need access to its private key so you can decrypt it. In
    practice that means you specify your own keybase account id.
    EOM
}

resource "aws_iam_user" "workshop_participant" {
  name = "spark-on-k8s-participant"
  path = "/system/"
}

resource "aws_iam_access_key" "iam_secret_key" {
  user    = aws_iam_user.workshop_participant.name
  pgp_key = "keybase:${var.keybase_user}"
}

resource "aws_iam_group" "group" {
  name = local.groupname
}

resource "aws_iam_group_policy_attachment" "secretmgrreadwrite" {
  group      = aws_iam_group.group.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_group_policy_attachment" "s3-access" {
  group      = aws_iam_group.group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "console_access_ecr" {
  group = aws_iam_group.group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_group_policy_attachment" "eks_cluster_policy" {
  # description: This policy provides Kubernetes the permissions it requires to
  # manage resources on your behalf. Kubernetes requires Ec2:CreateTags
  # permissions to place identifying information on EC2 resources including but
  # not limited to Instances, Security Groups, and Elastic Network Interfaces. 
  group = aws_iam_group.group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_group_policy_attachment" "eks_workers_policy" {
  # description: This policy allows Amazon EKS worker nodes to connect to
  # Amazon EKS Clusters. 
  group = aws_iam_group.group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_user_group_membership" "participant_group" {
  user     = aws_iam_user.workshop_participant.name
  groups   = [aws_iam_group.group.name]
}
