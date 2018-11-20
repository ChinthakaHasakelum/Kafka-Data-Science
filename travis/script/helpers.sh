# WARNING: This file is deployed from template. Raise a pull request against terraform-template to change.

b64_decode() {
  uname -s | egrep Darwin >/dev/null && base64 -D || base64 -d
}

kms_decrypt() {
  local encrypted=$1
  aws kms decrypt \
  --region eu-west-1 \
  --ciphertext-blob fileb://<(echo "$encrypted" | b64_decode) \
  --output text --query Plaintext | b64_decode
}

decrypt() {
  local key=$1
  local encrypted=$(egrep "^ *$key[ =]" secrets.tfvars)
  encrypted=$(echo "$encrypted" | sed -e "s/^ *$key[ = ]*//" | tr -d '"')
  kms_decrypt "$encrypted"
}

init_ssh() {
  eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_rsa
  ssh -T git@github.com || true
}

manage_env_create() {
  cd "${TRAVIS_BUILD_DIR}/bitesize-environments"
  git pull
  [[ -d "dev/${REGION}/${PR_ENV_NAME}/" ]] || ./manage-env.py create --env "${PR_ENV_NAME}" --region "${REGION}" --envtype dev --travis --pause-schedule="" --unpause-schedule=""
  cd "dev/${REGION}/${PR_ENV_NAME}"
  echo "{ \"$module_version_var\": \"$module_version\" }" > versions.tf.json
  echo node_count = 6 >> kube-minion/terraform.tfvars
  cp "${TRAVIS_BUILD_DIR}/travis/script/secrets.tfvars" .
}
