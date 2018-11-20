resource "aws_iam_role" "server" {
  name = "${local.globalname}-server"
  path = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "server" {
  name = "${local.globalname}-server"
  role  = "${aws_iam_role.server.name}"
  lifecycle {
    create_before_destroy = true
  }
  provisioner "local-exec" {
    command = "sleep 10"
  }
}


# ----
# Policy attachments

resource "aws_iam_policy_attachment" "s3" {
  name       = "${local.globalname}-s3"
  roles      = ["${aws_iam_role.server.name}"]
  policy_arn = "${aws_iam_policy.s3_policy.arn}"
}

resource "aws_iam_policy_attachment" "cloudwatch_stat" {
  name       = "${local.globalname}-cloudwatch-stat"
  roles      = [ "${aws_iam_role.server.name}" ]
  policy_arn = "${aws_iam_policy.cloudwatch_stat.arn}"
}

resource "aws_iam_policy_attachment" "github_ro_key" {
  name       = "${local.globalname}-github_ro_key"
  roles      = [ "${aws_iam_role.server.name}" ]
  policy_arn = "${aws_iam_policy.ssm_policy.arn}"
}

resource "aws_iam_policy_attachment" "ec2_inventory" {
  name       = "${local.globalname}-ec2-inventory"
  roles      = ["${aws_iam_role.server.name}"]
  policy_arn = "${aws_iam_policy.ec2_inventory_policy.arn}"
}

resource "aws_iam_policy_attachment" "sns" {
  name       = "${local.globalname}-sns"
  roles      = [ "${aws_iam_role.server.name}" ]
  policy_arn = "${aws_iam_policy.sns.arn}"
}

# ----
# Policies

resource "aws_iam_policy" "cloudwatch_stat" {
  name        = "${local.globalname}-cloudwatch-stat"
  path        = "/"
  description = "Policy allows to push memory stats to CloudWatch - ${local.globalname}"
  policy      = "${data.aws_iam_policy_document.cloudwatch_stats.json}"
}

resource "aws_iam_policy" "ssm_policy" {
  name        = "${local.globalname}-ssm-policy"
  path        = "/"
  description = "Policy allows to retrieve github_ro_key from AWS SSM ParameterStore"
  policy      = "${data.aws_iam_policy_document.ssm.json}"
}

resource "aws_iam_policy" "s3_policy" {
  name        = "${local.globalname}-s3-policy"
  path        = "/"
  description = "Policy to access ${var.environment} with Bitesize server S3 bucket"
  policy      = "${data.aws_iam_policy_document.s3.json}"
}

resource "aws_iam_policy" "ec2_inventory_policy" {
  name        = "${local.globalname}-ec2-inventory-policy"
  path        = "/"
  description = "Policy allows boto3 client to build EC2 inventory for ${var.environment} environment"
  policy      = "${data.aws_iam_policy_document.ec2_inventory.json}"
}

resource "aws_iam_policy" "sns" {
  name        = "${local.globalname}-sns"
  path        = "/"
  description = "Policy to publish to sns from ${local.globalname}"
  policy      = "${data.aws_iam_policy_document.sns.json}"
}

