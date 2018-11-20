## terraform-mongo

## Building and Testing

**Pre-requisites:**
 
* Make
* Terraform 0.11.7
  **Note:** use the version of Terraform specified
* AWSpec 1.2.0 (gem install awspec -v 1.2.0)
* `~/.aws/credentials` file with a default profile that has access to a Pearson AWS account

**Information:** If you use a later version it will force everyone else to upgrade. This then creates work to update the build system. We would like to schedule this work in advance and not get sidetracked.

To build and test the Terraform code by run:

* `make`

**Information:** This loads a set of environment variables that from `test/dev.env` and sets your currently logged on user as the environment name. Terraform runs { init, plan, apply } in the *module dir*, creating resources in AWS.

**Result:** AWSpec tests execute against the AWS API to check resources.
 
Alternatively run:
 
`make init` `make plan` `make apply` `make test`

**Information:** follow the usual Terraform workflow.

It is common to make changes to the module while iteratively running

* `make apply`

To work on tests update `test/unit/spec/*_spec.rb` files and test them against the infrastructure using:

* `make test`

**Information** the output is pipelined from terraform into `test/unit/spec/output.json` as an input into the spec files. If you add or remove from this module update `module/outputs.tf` and the `/test/unit/spec` tests.

Use *us-west-2* to perform local Terraform testing and Travis Pull Request builds.

To clean up all AWS resources, run:

`make destroy`
