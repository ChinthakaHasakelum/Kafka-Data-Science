#!/bin/bash

# WARNING: This file is deployed from template. Raise a pull request against terraform-template to change.

source $(dirname $0)/helpers.sh
set -x

PR_ENV_NAME="u${TRAVIS_COMMIT:0:7}"
UNIT_FAILED=0

main() {
  init_ssh
  cd "${TRAVIS_BUILD_DIR}"
  [[ ! -d module ]] || make || UNIT_FAILED=1
  final
}
final() {
  [[ ! -d module ]] || make destroy
  ${TRAVIS_BUILD_DIR}/bitesize-environments/tools/delete-env.py --env ${PR_ENV_NAME} --region us-west-2 --envtype dev
  [[ "$UNIT_FAILED" -eq "0" ]] || exit 1
}

time main
