#!/bin/bash

# WARNING: This file is deployed from template. Raise a pull request against terraform-template to change.

set -e
set -x
e=0

# Force origin to Git
git remote set-url origin git@github.com:pearsontechnology/${REPO_NAME}.git

# Install Terraform
terraform --version || e=$? ; if echo $e | egrep 127 ; then
  wget -q https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip -O /tmp/terraform.zip
  unzip /tmp/terraform.zip -d /home/travis/bin/
  e=0
fi

# Install JQ
jq --version || e=$? ; if echo $e | egrep 127 ; then
  wget -q https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -O /home/travis/bin/jq
  chmod +x /home/travis/bin/jq
  e=0
fi

# Install Python pips (we use pytest for integration tests)
pip list
pip install awscli boto3 jinja2 pytest ipaddress

# Pull down a key from AWS for checkout out Github repos
if [[ $TRAVIS == true ]] ; then
  aws ssm get-parameters --names "github_rw_key" --region eu-west-1 --with-decryption | jq -r ".Parameters[0].Value" > ~/.ssh/id_rsa
  echo -e "Host *\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
fi
chmod 600 ~/.ssh/id_rsa

# Install our binaries
eval `ssh-agent -s` && ssh-add ~/.ssh/id_rsa

# If this is bitesize-environments, just link the current folder to "bitesize-environments":
be=bitesize-environments
if [[ $REPO_NAME == $be ]]; then
  [[ -d $be ]] || mkdir $be
  (echo .git; ls -1d *) | while read x; do
    [[ $x != dev ]] || continue
    [[ $x != $be ]] || continue
    if [[ ! -e $be/$x ]] ; then
      [[ -d $x ]] && ln -s ../$x/ $be/$x || ln -s ../$x $be/$x
    fi ;
  done ;
  [[ -d $be/dev ]] || mv dev $be/
  [[ ! -d dev ]] || rm -r dev
  ln -s $be/dev/ dev
fi ;

# If we haven't cloned Git repo, clone it:
[[ -d bitesize-environments/.git ]] \
|| git clone git@github.com:pearsontechnology/bitesize-environments.git

# Install Terragrunt and Terraform plugins from bitesize-environments:
[[ -e /home/travis/bin/terragrunt ]] \
|| cp bitesize-environments/tools/terragrunt-bitesize-linux-amd64 /home/travis/bin/terragrunt
chmod +x /home/travis/bin/terragrunt
[[ -d /home/travis/.terraform.d/plugins/linux_amd64 ]] \
|| mkdir -p /home/travis/.terraform.d/plugins/linux_amd64
[[ -e /home/travis/.terraform.d/plugins/linux_amd64/terraform-provider-cidr ]] \
|| cp bitesize-environments/tools/terraform-provider-cidr-linux-amd64 /home/travis/.terraform.d/plugins/linux_amd64/terraform-provider-cidr
[[ -e /home/travis/.terraform.d/plugins/linux_amd64/terraform-provider-secret ]] \
|| cp bitesize-environments/tools/terraform-provider-secret-linux-amd64 /home/travis/.terraform.d/plugins/linux_amd64/terraform-provider-secret


# Install Terraform unit test tool awspec
if [[ -d ${TRAVIS_BUILD_DIR}/module ]] ; then
  # Install Terraform unit test tool awspec
  gem which awspec && gem list awspec | egrep '^awspec \(1\.2\.0\)$' || gem install awspec -v 1.2.0
fi ;

# Install kubectl binary
kubectl help >/dev/null || e=$? ; if echo $e | egrep 127 ; then
  [[ -e /home/travis/bin/kubectl ]] \
  || wget -q https://storage.googleapis.com/kubernetes-release/release/v1.7.14/bin/linux/amd64/kubectl -O /home/travis/bin/kubectl
  chmod +x /home/travis/bin/kubectl
fi ;
