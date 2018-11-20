
output "region" {
  value = "${var.region}"
}

output "env" {
  value = "${var.environment}"
}

output "fullname" {
  value = "${local.fullname}"
}

output "inbound_whitelist" {
  value = "${var.inbound_whitelist}"
}

output "asg_id" {
  value = "${aws_autoscaling_group.mongo.id}"
}

output "vpc_id" {
  value = "${data.aws_vpc.bitesize.id}"
}

output "aws_launch_configuration" {
  value = "${aws_launch_configuration.mongo.name}"
}

output "aws_autoscaling_group" {
  value = "${aws_autoscaling_group.mongo.name}"
}