data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket     = "${var.s3_bucket}"
    key        = "${var.region}/${var.environment}/tfstate/core/terraform.tfstate"
    region     = "${var.region}"
  }
}

module "mod" {

  source = "../module"
  #
  # variables that can be overwritten by tfvars, but usually come from core
  #

  vpc_id    = "${var.vpc_id != "" ? var.vpc_id : data.terraform_remote_state.core.vpc_id}"
  vpc_db_id = "${var.vpc_db_id != "" ? var.vpc_db_id : data.terraform_remote_state.core.vpc_db_id}"

  internal_zone_id = "${var.internal_zone_id != "" ? var.internal_zone_id : data.terraform_remote_state.core.internal_zone_id}"
  external_zone_id = "${var.external_zone_id != "" ? var.external_zone_id : data.terraform_remote_state.core.external_zone_id}"

  internal_zone_name = "${var.internal_zone_name != "" ? var.internal_zone_name : data.terraform_remote_state.core.internal_zone_name}"
  external_zone_name = "${var.external_zone_name != "" ? var.external_zone_name : data.terraform_remote_state.core.external_zone_name}"

  instance_subnet_ids     = "${data.terraform_remote_state.core.bitesize_backend_subnet_ids}"
  loadbalancer_subnet_ids = "${data.terraform_remote_state.core.bitesize_frontend_subnet_ids}"

  #
  # variables that can be overwritten by tfvars
  #

  environment             = "${var.environment}"
  environment_type        = "${var.environment_type}"
  region                  = "${var.region}"
  aws_key_name            = "${var.aws_key_name}"
  inbound_whitelist       = "${var.inbound_whitelist}"
  s3_bucket               = "${var.s3_bucket}"
  default_tags            = "${var.default_tags}"
  centos_ami_filter       = "${var.centos_ami_filter}"
  shared_credentials_file = "${var.shared_credentials_file}"
  remote_state_s3_region  = "${var.remote_state_s3_region}"

  #
  # ansible variables
  #

  ansible_users_version = "${var.ansible_users_version}"
  instance_type = "${var.instance_type}"
  external_route53_zone_id = "${var.external_route53_zone_id}"
  kube_route53_zone_id = "${var.kube_route53_zone_id != "" ? var.kube_route53_zone_id : data.terraform_remote_state.core.kube_zone_id}"

  skip_ansible="${var.skip_ansible}"
}

