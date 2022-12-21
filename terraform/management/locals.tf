locals {
  env             = "mgmt"
  region          = "eu-west-3"
  cluster_name    = "${local.env}-vital-bird" # Generated using petname
  cluster_version = "1.24"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    GithubRepo = "flux-karpenter"
    GithubOrg  = "Smana"
  }
}
