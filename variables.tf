###################################################
# Regions & Profile
###################################################

variable "sg" {
  description = "ap-southeast-1 — hosts customer-profile VPC"
  default     = "ap-southeast-1"
}

variable "au" {
  description = "ap-southeast-2 — hosts account VPC"
  default     = "ap-southeast-2"
}

variable "jp" {
  description = "ap-northeast-1 — hosts statement VPC"
  default     = "ap-northeast-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  default     = "admin"
}

###################################################
# General
###################################################

variable "prefix" {
  description = "Prefix included in the name of most resources."
}

variable "environment" {
  description = "Target environment."
  default     = "dev"
}

variable "admin_ip" {
  description = "Your public IP for SSH access (e.g. 1.2.3.4/32)."
  type        = string
}

###################################################
# VPC CIDRs
###################################################

variable "customer_vpc_cidr" {
  description = "CIDR for customer VPC (ap-southeast-1)"
  default     = " "
}

variable "account_vpc_cidr" {
  description = "CIDR for account VPC (ap-southeast-2)"
  default     = " "
}

variable "statement_vpc_cidr" {
  description = "CIDR for statement VPC (ap-northeast-1)"
  default     = " "
}

###################################################
# Subnet CIDRs
###################################################

variable "customer_public_cidr" {
  type    = list(string)
  default = []
}

variable "customer_private_cidr" {
  type    = list(string)
  default = []
}

variable "account_public_cidr" {
  type    = list(string)
  default = []
}

variable "account_private_cidr" {
  type    = list(string)
  default = []
}

variable "statement_public_cidr" {
  type    = list(string)
  default = []
}

variable "statement_private_cidr" {
  type    = list(string)
  default = []
}

###################################################
# EC2
###################################################

variable "instance_type" {
  description = "EC2 instance type for all services."
  type        = string
  default     = "t3.micro"
}