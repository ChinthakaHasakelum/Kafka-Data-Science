resource "aws_sqs_queue" "ansible" {
  name = "${local.fullname}"
  message_retention_seconds = 300
}

resource "aws_sns_topic_subscription" "ansible" {
  topic_arn = "${aws_sns_topic.ansible.arn}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.ansible.arn}"
}

resource "aws_sqs_queue_policy" "ansible" {
  queue_url = "${aws_sqs_queue.ansible.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.ansible.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.ansible.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "null_resource" "feedback" {

  depends_on = ["aws_sqs_queue.ansible", "aws_autoscaling_group.mongo", "aws_sqs_queue_policy.ansible"]

  provisioner "local-exec" {
    command = "./recv_msg.py --threshold 1 --count ${var.node_count} --env ${var.environment} --envtype ${var.environment_type} --region ${var.region} --resource ${var.db_instance_name}-${var.namespace}-${var.role} --skip ${var.skip_ansible}"
  }

  triggers {
    document = "${uuid()}"
  }
}

