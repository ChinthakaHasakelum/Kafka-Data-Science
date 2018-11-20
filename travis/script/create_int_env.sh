# WARNING: This file is deployed from template. Raise a pull request against terraform-template to change.

source $(dirname $0)/helpers.sh
source $(dirname $0)/int.env
set -x

if [[ -e "${TRAVIS_BUILD_DIR}/integration_disabled" ]]; then exit 0; fi

init() {
    init_ssh
}

main() {
    init \
    && manage_env_create \
    && cd ${MODULE} \
    && terragrunt_apply
}

terragrunt_apply() {
    travis_ip=$(curl -s https://dnsjson.com/nat.linux-containers.travisci.net/A.json | jq '[.results.records   | .[] + "/32"]' | tr -d '\n')
    terragrunt apply \
    -var "inbound_whitelist=$travis_ip" \
    --terragrunt-source-update \
    --terragrunt-non-interactive --auto-approve --parallelism=5
}

time main
