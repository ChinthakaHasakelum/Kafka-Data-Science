# WARNING: This file is deployed from template. Raise a pull request against terraform-template to change.

source $(dirname $0)/helpers.sh
source $(dirname $0)/int.env
set -x

if [[ -e "${TRAVIS_BUILD_DIR}/integration_disabled" ]]; then exit 0; fi

init() {
    init_ssh
    manage_env_create
    source $(dirname $0)/int.env
    init_kubectl
}

main() {
    init
    python_up
    run_pytests
}

init_kubectl() {
    echo "Setting up kubectl config"
    kubectl config set-cluster default \
            --server=https://master.${PR_ENV_NAME}.${REGION}.${EXT_DOMAIN} \
            --insecure-skip-tls-verify
    kubectl config set-context default --cluster=default --user=admin
    kubectl config set-credentials admin --username=admin --password="${KUBERNETES_PASSWORD}"
    kubectl config use-context default
}

python_up() {
  get_int_tests \
  && install_py_requirements
}

freshen() {
  (cd "test/integration"/ && git fetch origin && git checkout ${INTEGRATION_REF:-master} && git pull)
}

link_test_integration_dir() {
    bi=bitesize-integration
    dest=integration
    src=..
    if [[ $REPO_NAME == $bi ]]; then
      rsync -a --exclude .git $src/ $dest
      [[ ! -e "$dest/test/integration" ]] || rm -rf "$dest/test/integration"
    fi ;
}

get_int_tests() {
  cd "${TRAVIS_BUILD_DIR}/"
  [[ $REPO_NAME != bitesize-integration ]] || [[ ! -L test/integration ]] || rm test/integration
  if [[ -d test/integration ]] ; then
    [[ $REPO_NAME == bitesize-integration ]] || freshen
  else
    if [[ $REPO_NAME == bitesize-integration ]] ; then
      cd test && link_test_integration_dir
      cd "${TRAVIS_BUILD_DIR}/"
    else
      git clone -b ${INTEGRATION_REF:-master} \
      git@github.com:pearsontechnology/bitesize-integration.git "test/integration"
    fi ;
  fi ;
}

install_py_requirements() {
    cd "${TRAVIS_BUILD_DIR}/"
    pip install virtualenv \
    && virtualenv pytestenv
    . pytestenv/bin/activate
    pip install -r "test/integration/requirements.txt"
}

run_pytests() {
  if [[ $REPO_NAME == "terraform-couchbase" ]]; then
      export TEST_LIST=couchbase
      export TEST_TYPE=integration
      export COUCHBASE_VERSION=${module_version}
  fi
  cd "${TRAVIS_BUILD_DIR}/test/integration" \
  && pytest test
}

time main
