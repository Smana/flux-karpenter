# Demo cluster we need to access to the API publicly
#tfsec:ignore:aws-eks-no-public-cluster-access
#tfsec:ignore:aws-eks-no-public-cluster-access-to-cidr
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.4"

  cluster_name                   = local.cluster_name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

  cluster_addons = {
    kube-proxy = {}
    vpc-cni    = {}
    coredns = {
      configuration_values = jsonencode({
        computeType = "Fargate"
      })
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  create_cluster_security_group = false
  create_node_security_group    = false

  fargate_profile_defaults = {
    iam_role_additional_policies = {
      additional = aws_iam_policy.additional.arn
    }
  }

  fargate_profiles = {
    main = {
      name = "main"
      selectors = [
        {
          namespace = "flux-system"
        }
      ]

      subnet_ids = [module.vpc.private_subnets[1]]

      tags = {
        Application = "Flux"
      }

      timeouts = {
        create = "20m"
        delete = "20m"
      }
    }

    kube_system = {
      name = "kube-system"
      selectors = [
        {
          namespace = "kube-system"
        }
      ]
    }
  }

  tags = local.tags
}
