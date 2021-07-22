locals {
  # Automatically load environment-level variables
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out common variables for reuse
  map_users    = local.account_vars.locals.map_users
  map_accounts = local.account_vars.locals.map_accounts

  env = local.environment_vars.locals.environment

  region = local.region_vars.locals.aws_region
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
# terraform {
#   source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-modules-example.git//mysql?ref=v0.4.0"
# }

terraform {

  # the below config is an example of what the config should like
  # source = "git::git@github.com:gruntwork-io/terragrunt-modules.git//aws/env_cluster_nodegroup?ref=v0.4.0"

  source = "git::git@github.com:argonautdev/terragrunt-modules.git//aws/vpc?ref={{ .RefVersion }}"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("backend.hcl")
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  default_tags = {
    "argonaut.dev/name"        = "${local.env}"
    "argonaut.dev/type"        = "VPC"
    "argonaut.dev/manager"     = "argonaut.dev"
    "argonaut.dev/environment" = "${local.env}"
  }
  aws_region                 = "${local.region}"
  # vpc name should be same as env name
  name                       = "${local.env}"
  cidr_block                 = "20.10.0.0/16" # 10.0.0.0/8 is reserved for EC2-Classic
  enable_vpn_gateway         = true
  public_subnet_count        = 2
  private_subnet_count       = 2
  public_subnet_cidr_blocks  = ["20.10.11.0/24", "20.10.12.0/24", "20.10.13.0/24"]
  private_subnet_cidr_blocks = ["20.10.1.0/24", "20.10.2.0/24", "20.10.3.0/24"]
  enable_dns_hostnames       = true
  enable_nat_gateway         = true
  single_nat_gateway         = true
}
