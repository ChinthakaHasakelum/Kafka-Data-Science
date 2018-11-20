resource "aws_launch_configuration" "mongo" {
  image_id                    = "${data.aws_ami.centos.id}"
  name_prefix                 = "${local.fullname}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.aws_key_name}"
  security_groups             = ["${aws_security_group.mongo.id}"]
  user_data                   = "${module.bootstrap.user_data}"
  iam_instance_profile        = "${aws_iam_instance_profile.server.name}"
  ebs_optimized               = "${var.ebs_optimized}"
  associate_public_ip_address = true
  

  connection {
    user  = "centos"
    agent = true
  }


  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

  # docker
  ebs_block_device {
    device_name           = "/dev/xvdb"
    volume_type           = "gp2"
    volume_size           = 100
    encrypted             = "true"
  }

  # data
  ebs_block_device {
    device_name           = "/dev/xvdc"
    volume_type           = "${var.volume_type}"
    volume_size           = "${var.data_size}"
    encrypted             = "true"
    iops                  = "${var.data_iops}"
  }


  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "mongo" {
  vpc_zone_identifier       = ["${var.instance_subnet_ids}"]
  name                      = "${local.fullname}"
  max_size                  = "${var.node_count}"
  min_size                  = "${var.node_count}"
  health_check_grace_period = 100
  health_check_type         = "EC2"
  desired_capacity          = "${var.node_count}"
  force_delete              = false
  launch_configuration      = "${aws_launch_configuration.mongo.name}"
  #public ip 
  #associate_public_ip_address = true
 
  lifecycle {
    create_before_destroy = true
  }

  tags = ["${concat(
    list(
      map("key", "Name", "value", "${local.fullname}", "propagate_at_launch", true),
      map("key", "Role", "value", "${var.role}", "propagate_at_launch", true),
      map("key", "ssm", "value", "${local.fullname}", "propagate_at_launch", true),
    ),
    var.default_asg_tags)
  }"]

  depends_on = [
    "aws_launch_configuration.mongo",
    "aws_iam_instance_profile.server",
    "aws_iam_role.server",
  ]
}