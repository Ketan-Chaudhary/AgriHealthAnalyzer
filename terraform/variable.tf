variable "aws_region" { default = "ap-south-1" } #Aws Region to deploy resources in
variable "vpc_cidr" { default = "10.0.0.0/16" } #Main vpc CIDR block
variable "public_subnet_cidr" { default = "10.0.1.0/24" } # CIDR block for public subnet
variable "private_subnet_cidr" { default = "10.0.2.0/24" } # CIDR block for private subnet
variable "ami_id" { description = "AMI ID for EC2" } 
variable "instance_type" { default = "t2.micro" }
variable "ssh_key_name" {
  description = "The name of the SSH key pair for EC2 instances."
  type        = string
}
