resource "aws_sns_topic" "ansible" {
  name = "${local.fullname}"
}
