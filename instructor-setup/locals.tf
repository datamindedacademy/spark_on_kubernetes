locals {
  aws_region       = "eu-west-1"
  account_id       = "338791806049"
  account_alias    = "data-minded-academy"
  profile          = "academy"
  users            = {
      "academystudent" = null
  }
  default_password = "Data Minded r0cks!"
  groupname        = "workshop-participants"
  subnet_id        = "subnet-6b690731"
}
