# Tell Terraform to use AWS as the provider
provider "aws" {
	region = var.aws_region
}

# Fetch list of available availability zones in the region
data "aws_availability_zones" "available" {}
