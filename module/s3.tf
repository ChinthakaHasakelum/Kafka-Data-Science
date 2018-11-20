resource "aws_s3_bucket_object" "requirements" {
  provider = "aws.shared"
  bucket  = "${var.s3_bucket}"
  key     = "${var.region}/${var.environment}/files/${local.backwards}/requirements.yaml"
  content = "${data.template_file.requirements.rendered}"
}

resource "aws_s3_bucket_object" "playbook" {
  provider = "aws.shared"
  bucket  = "${var.s3_bucket}"
  key     = "${var.region}/${var.environment}/files/${local.backwards}/site.yaml"
  content = "${data.template_file.playbook.rendered}"
}

resource "aws_s3_bucket_object" "extra_vars" {
  provider = "aws.shared"
  bucket  = "${var.s3_bucket}"
  key     = "${var.region}/${var.environment}/files/${local.backwards}/extra_vars.yaml"
  content = "${data.template_file.extra_vars.rendered}"
}

resource "aws_s3_bucket_object" "aws_config" {
  provider = "aws.shared"
  bucket  = "${var.s3_bucket}"
  key     = "${var.region}/${var.environment}/files/${local.backwards}/aws-config"
  source  = "${path.module}/files/aws-config"
}
