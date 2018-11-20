resource "aws_ssm_document" "ansible" {
  name          = "${local.fullname}-ansible"
  document_type = "Command"

  content = <<DOC
  {
    "schemaVersion": "2.2",
    "description": "Run ansible on ${local.fullname}",
    "parameters": {

    },
    "mainSteps": [
      {
        "action": "aws:runShellScript",
        "name": "runAnsible",
        "inputs": {
          "runCommand": ["/bin/ansible-wrapper.sh"]
        }
      }
    ]
  }
DOC
}

resource "aws_ssm_association" "ansible" {
  name        = "${local.fullname}-ansible"
  targets {
    key = "tag:ssm"
    values = ["${local.fullname}"]
  }

  depends_on = ["aws_ssm_document.ansible"]
}

resource "null_resource" "provisioner" {

  provisioner "local-exec" {
    command = "aws ssm update-association --region ${var.region} --association-id ${aws_ssm_association.ansible.association_id}"
  }

  triggers {
    document = "${uuid()}"
  }
  depends_on = ["aws_ssm_association.ansible",
    "aws_s3_bucket_object.requirements",
    "aws_s3_bucket_object.playbook",
    "aws_s3_bucket_object.extra_vars",
    "aws_s3_bucket_object.aws_config"
  ]
}
