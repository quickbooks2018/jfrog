terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = "~> 1.0"
}


### Backend ###
# S3
###############

terraform {
  backend "s3" {
    bucket         = "terraform-cloudgeeks"
    key            = "env/dev/cloudgeeks-dev.tfstate"
    region         = "us-east-1"
    # dynamodb_table = "cloudgeeks-dev-terraform-backend-state-lock"
  }
}

######
# VPC
######

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.4.0"

  name            = "cloudgeeks-vpc"

  cidr            = "10.60.0.0/16"
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.60.0.0/23", "10.60.2.0/23", "10.60.4.0/23"]
  public_subnets  = ["10.60.100.0/24", "10.60.101.0/24", "10.60.102.0/24"]


  map_public_ip_on_launch = true
  enable_nat_gateway      = true
  single_nat_gateway      = true
  one_nat_gateway_per_az  = false

  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = false
  create_database_nat_gateway_route      = true

  enable_dns_hostnames = true
  enable_dns_support   = true

}

##############
# EC2 Key Pair  # ssh-keygen -t ed25519 -f cloudgeeks -C "default"
##############
module "ec2-keypair" {
  source = "./modules/key-pair"
  key_name      = "cloudgeeks"
  public_key    = file("./modules/secrets/cloudgeeks.pub")
}

######################
# EC2 Instance Profile
######################
module "iam-instance-profile" {
  source        = "./modules/instance-profile/ec2"
  ec2_role_name = "ec2_console"
}


module "jfrog-security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"
  name    = "jfrog"
  vpc_id  = module.vpc.vpc_id

  computed_ingress_with_cidr_blocks = [

    {
      from_port   = 8082
      to_port     = 8082
      protocol    = 6
      description = "Web HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  number_of_computed_ingress_with_cidr_blocks = 1

  computed_egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "All Out Bound Allowed"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  number_of_computed_egress_with_cidr_blocks = 1
}

module "jenkins-security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"
  name    = "jfrog"
  vpc_id  = module.vpc.vpc_id

  computed_ingress_with_cidr_blocks = [

    {
      from_port   = 8080
      to_port     = 8080
      protocol    = 6
      description = "Web HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  number_of_computed_ingress_with_cidr_blocks = 1

  computed_egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "All Out Bound Allowed"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  number_of_computed_egress_with_cidr_blocks = 1
}


######
# EC2
######

module "jfrog-ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.0"
  for_each = toset(["one"])

  name                       = "jfrog"
  key_name                   = module.ec2-keypair.key_pair_name
  # Ubuntu-22-LTS
  ami                         = "ami-0c7217cdde317cfec"
  instance_type               = "t3a.medium"
  associate_public_ip_address = true
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [module.jfrog-security-group.security_group_id]
  iam_instance_profile        = module.iam-instance-profile.ec2_instance_profile_name
  disable_api_termination     = true
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 30
    },
  ]
  user_data  = file("../userdata/jfrog.sh")
}

module "jenkins-ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.0"
  for_each = toset(["one"])

  name                       = "jenkins"
  key_name                   = module.ec2-keypair.key_pair_name
  # Ubuntu-22-LTS
  ami                         = "ami-0c7217cdde317cfec"
  instance_type               = "t3a.medium"
  associate_public_ip_address = true
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [module.jfrog-security-group.security_group_id]
  iam_instance_profile        = module.iam-instance-profile.ec2_instance_profile_name
  disable_api_termination     = true
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 30
    },
  ]
  user_data_base64            = <<-EOF
IyEvYmluL2Jhc2gKYXB0IHVwZGF0ZSAteQoKIyBEb2NrZXIgSW5zdGFsbGF0aW9uCmN1cmwgLWZzU0wgaHR0cHM6Ly9nZXQuZG9ja2VyLmNvbSAtbyBpbnN0YWxsLWRvY2tlci5zaApzaCBpbnN0YWxsLWRvY2tlci5zaAoKIyBEb2NrZXIgcnVuIEplbmtpbnMKZG9ja2VyIG5ldHdvcmsgY3JlYXRlIGplbmtpbnMgLS1hdHRhY2hhYmxlCmRvY2tlciBydW4gLS1uYW1lIGplbmtpbnMgLS1uZXR3b3JrIGplbmtpbnMgLXcgL3Zhci9qZW5raW5zX2hvbWUgLWlkIC12IGplbmtpbnM6L3Zhci9qZW5raW5zX2hvbWUgLXAgODA4MDo4MDgwIC12ICQod2hpY2ggZG9ja2VyKTovdXNyL2Jpbi9kb2NrZXIgLXYgL3Zhci9ydW4vZG9ja2VyLnNvY2s6L3Zhci9ydW4vZG9ja2VyLnNvY2sgLS1yZXN0YXJ0IHVubGVzcy1zdG9wcGVkIGplbmtpbnMvamVua2luczpsdHMKCiMgRW5kIG9mIFNjcmlwdA==
    EOF
}
