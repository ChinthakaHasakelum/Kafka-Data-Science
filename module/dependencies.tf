module "bootstrap" {
  source                   = "git::ssh://git@github.com/pearsontechnology/terraform-bootstrap.git//module"
  version                  = "${var.terraform_bootstrap_version}"
  s3_bucket                = "${var.s3_bucket}"
  s3_bucket_path           = "${var.region}/${var.environment}/files/mg-${var.namespace}-${var.db_instance_name}"
  notification_service_arn = "${aws_sns_topic.ansible.arn}"
  role                     = "${local.backwards}"
}
