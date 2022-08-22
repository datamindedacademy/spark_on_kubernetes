resource "aws_ecr_repository" "registry" {
  name                 = "spark-on-k8s"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true
}
