# Create IAM users with a default password
resource "aws_iam_user" "workshop_participants" {
  for_each = local.users
  name     = each.key

  force_destroy = true

  provisioner "local-exec" {
    command = "python update_password.py --profile ${local.profile} --username ${each.key} --password \"${local.default_password}\""
  }

  provisioner "local-exec" {
    when    = destroy
    # TODO: ensure the profile can be configured.
    command = "python update_password.py --profile academy --username ${each.key} --delete"
  }
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
  for_each = aws_iam_user.workshop_participants
  user     = each.key
  groups   = [aws_iam_group.group.name]
}

resource "aws_iam_account_alias" "account" {
  account_alias = local.account_alias
}
