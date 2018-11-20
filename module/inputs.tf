variable "role" {
  default = "mg"
}

variable "node_count" {
  default = 3
}

variable "environment" {}

variable "environment_type" {
  default = "dev"
}

variable "vpc_id" {
  default = ""
}

variable "remote_state_s3_region" {
  default = "eu-west-1"
}

variable "external_route53_zone_id" {
  default = ""
}

variable "kube_route53_zone_id" {
  default = ""
}

variable "vpc_db_id" {
  default = ""
}

variable "default_tags" {
  type = "map"
  default = {}
}

variable "asg_tags" {
  type = "list"
  default = []
}

variable "default_asg_tags" {
  type    = "list"
  default = []
}


variable "s3_bucket" {}

variable "region" {
  default = "eu-west-1"
}

variable "centos_ami_filter" {
  default = "centos7-*"
}

variable "instance_subnet_ids" {
  type = "list"
  default = []
}

variable "db_subnet_ids" {
  type = "list"
  default = []
}


variable "loadbalancer_subnet_ids" {
  type = "list"
  default = []
}

variable "aws_key_name" {
  default = "bitesize"
}

variable "inbound_whitelist" {
  type = "list"
  default = []
}

variable "external_zone_id" {
  default = ""
}

variable "internal_zone_id" {
  default = ""
}

variable "external_zone_name" {
  default = ""
}

variable "internal_zone_name" {
  default = ""
}

variable "instance_type" {
  default = "m4.large"
}

variable "shared_credentials_file" {
  default = "~/.aws/credentials"
}

variable "skip_ansible" {
  default = "false"
}



#### Mongo variables ####

variable "namespace" {
  default = "mng"
}

variable "db_instance_name" {
  default = "instl"
}

variable "ebs_optimized" {
  default = "false"
}

variable "volume_type" {
  default = "gp2"
}

variable "data_iops" {
  default = "2500"
}

variable "data_size" {
  default = "200"
}