#!/usr/bin/env bash

# WARNING: This file is deployed from template. Raise a pull request against terraform-template to change.

set -e
set -x
# Decrypt AWS Credentials
mkdir ~/.aws
openssl aes-256-cbc -K $encrypted_21b9b5836851_key -iv $encrypted_21b9b5836851_iv -in credentials.enc -out credentials -d
