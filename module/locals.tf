locals {
  name = "${var.db_instance_name}-${var.namespace}-${var.role}"
  backwards = "${var.role}-${var.namespace}-${var.db_instance_name}"
  fullname = "${local.name}-${var.environment}-${var.environment_type}"
  globalname = "${local.name}-${var.environment}-${var.region}-${var.environment_type}"
  s3_folder  = "${var.region}/${var.environment}/files/${local.name}"

}
