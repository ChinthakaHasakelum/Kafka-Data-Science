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
    && terragrunt_destroy_all
}

terragrunt_destroy_all() {
    if [[ -d "$env_d/" ]] ; then
      cd "$env_d/" && \
      terragrunt destroy-all -force \
      --terragrunt-non-interactive \
      || (cd core && terragrunt destroy -force --terragrunt-non-interactive)
      delete_env
    fi;
}

delete_env() {
    cd "$env_d/" && \
    ../../../tools/delete-env.sh --confirm --thorough \
    && cd .. \
    && rm -rf "${PR_ENV_NAME:?}/"
}

time main
