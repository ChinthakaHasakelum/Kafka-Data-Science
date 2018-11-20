
data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.centos_ami_filter}"]
  }

  owners = ["815492460363", "602604727914"] # Bitesize-prod, Bitesize-Nonprod
}

data "aws_kms_alias" "ssm" {
  name = "alias/aws/ssm"
}

data "template_file" "playbook" {
  template = "${file("${path.module}/files/ansible/site.yaml.tmpl")}"
  
  vars = { 

  }
}

data "template_file" "requirements" {
  template = "${file("${path.module}/files/ansible/requirements.yaml.tmpl")}"
  vars = {
    ansible_users_version           = "${var.ansible_users_version}"
    ansible_mongo_version           = "${var.ansible_mongo_version}"
    ansible_cfssl_version           = "${var.ansible_cfssl_version}"
    ansible_route53_version         = "${var.ansible_route53_version}"
    ansible_volumes_version         = "${var.ansible_volumes_version}"
    ansible_td_agent_config_version = "${var.ansible_td_agent_config_version}"
    ansible_docker_version          = "${var.ansible_docker_version}"
  }
}

data "template_file" "extra_vars" {
  template = "${file("${path.module}/files/ansible/extra_vars.yaml.tmpl")}"
  vars = {
    region                    = "${var.region}"
    vpc_id                    = "${var.vpc_id}"
    internal_zone_name        = "${var.external_zone_name}"
    external_zone_name        = "${var.external_zone_name}"
    internal_zone_id          = "${var.external_zone_id}"
    external_zone_id          = "${var.external_zone_id}"
    bitesize_environment      = "${var.environment}"
    bitesize_environment_type = "${var.environment_type}"
    s3_bucket                 = "${var.s3_bucket}"
    role                      = "${var.role}"
    namespace                 = "${var.namespace}"
    db_instance_name          = "${var.db_instance_name}"
    asg_name_data             = "${aws_autoscaling_group.mongo.name}"
    
  }
}

data "aws_vpc" "bitesize" {
  id = "${var.vpc_id}"
}

data "aws_region" "shared" {
  provider = "aws.shared"
}

data "aws_iam_policy_document" "cloudwatch_stats" {
  statement {
    actions = [
      "cloudwatch:PutMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "ec2:DescribeTags"
    ]
    resources = [ "*" ]
  }
}

data "aws_iam_policy_document" "sns" {
  statement {
    actions = [
      "SNS:Publish"
    ]
    resources = [
      "${aws_sns_topic.ansible.arn}"
    ]
  }
}

data "aws_iam_policy_document" "s3" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListObjects",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:GetBucketLocation",
      "s3:deleteObject"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket}",
      "arn:aws:s3:::${var.s3_bucket}/${var.region}/${var.environment}/files/${local.backwards}/extra_vars.yaml",
      "arn:aws:s3:::${var.s3_bucket}/${var.region}/${var.environment}/files/${local.backwards}/site.yaml",
      "arn:aws:s3:::${var.s3_bucket}/${var.region}/${var.environment}/files/${local.backwards}/requirements.yaml",
      "arn:aws:s3:::${var.s3_bucket}/${var.region}/${var.environment}/files/${local.backwards}/aws-config",
      "arn:aws:s3:::${var.s3_bucket}/${var.environment}/${var.role}_backup*"
    ]
  }
}

data "aws_iam_policy_document" "ec2_inventory" {
  statement {
    actions = ["ec2:Describe*"]
    resources = ["*"]
  }

  statement {
    actions = ["elasticloadbalancing:Describe*"]
    resources = ["*"]
  }

  statement {
    actions = [
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:Describe*"
    ],
    resources = ["*"]
  }

  statement {
    actions = ["autoscaling:Describe*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ssm" {
  # TODO: This needs checking resources access
  statement {
    actions = [
      "ssm:DescribeParameters",
      "ssm:UpdateInstanceInformation",
      "ssm:UpdateInstanceAssociationStatus",
      "ssm:ListAssociations",
      "ssm:ListInstanceAssociations",
      "ssm:UpdateInstanceAssociationStatus",
      "ssm:GetDocument",
      "ec2messages:*"
    ]

    resources = [ "*" ]
  }

  statement {
    effect = "Allow"
    actions = [ "ssm:GetParameters" ]
    resources = [ "arn:aws:ssm:eu-west-1:*:parameter/github_ro_key" ]
  }

  statement {
    effect = "Allow"
    actions = [ "kms:Decrypt" ]
    resources = [ "${data.aws_kms_alias.ssm.arn}" ]
  }
}
