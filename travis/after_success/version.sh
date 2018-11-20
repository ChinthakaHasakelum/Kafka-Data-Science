#!/bin/bash

# WARNING: This file is deployed from template. Raise a pull request against terraform-template to change.

set -e
set -x

eval `ssh-agent -s` && ssh-add ~/.ssh/id_rsa

# Don't version template changes
commit_message=$(git log --format=%B -n 1 ${TRAVIS_COMMIT} | head -1)
if [ "$commit_message" == "update from terraform-template" ]; then
  echo "Not versioning template update"
  exit 0
fi

# Don't version bitesize-environments non-version changes
if [ "$REPO_NAME" == "bitesize-environments" ]; then
  if ! git show --stat --oneline $TRAVIS_COMMIT | grep versions.tf.json ; then
    echo "Not versioning bitesize-environments non-version change"
    exit 0
  fi
fi

# Tag Github repo with version prefix from version.txt and semver patch + 1
prefix=$(cat ${TRAVIS_BUILD_DIR}/version.txt)
latest_tag=$(git ls-remote --tags origin | cut -f 3 -d '/' | grep "^${prefix}" | sort -t. -k 3,3nr | head -1)
if [ -z ${latest_tag} ]; then
  VERSION_TAG="${prefix}.0"
else
  VERSION_TAG="${latest_tag%.*}.$((${latest_tag##*.}+1))"
fi
git tag ${VERSION_TAG}
git push --tags


# Send a webhook to trigger the next pull-request
generate_post_data()
{
  cat <<EOF
{
    "REPO_NAME": "$REPO_NAME",
    "MODULE": "$MODULE",
    "GITHUB_PR": "$(echo $TRAVIS_COMMIT_MESSAGE | grep 'Merge pull request ' | cut -d ' ' -f 4)",
    "VERSION_TAG": "$VERSION_TAG",
    "TRAVIS_BRANCH": "$TRAVIS_BRANCH",
    "TRAVIS_BUILD_ID": "$TRAVIS_BUILD_ID",
    "TRAVIS_BUILD_NUMBER": "$TRAVIS_BUILD_NUMBER",
    "TRAVIS_COMMIT_MESSAGE": "$(echo $TRAVIS_COMMIT_MESSAGE | tr -d '\000-\011\013\014\016-\037' | tr -d \")",
    "TRAVIS_COMMIT_RANGE": "$TRAVIS_COMMIT_RANGE",
    "TRAVIS_JOB_ID": "$TRAVIS_JOB_ID",
    "TRAVIS_JOB_NUMBER": "$TRAVIS_JOB_NUMBER",
    "TRAVIS_REPO_SLUG": "$TRAVIS_REPO_SLUG"
}
EOF
}

curl checkip.amazonaws.com || true

curl -i \
-H "Accept: application/json" \
-H "Content-Type:application/json" \
-X POST --data "$(generate_post_data)" "http://platformsbot.travis-pr.us-west-2.dev.prsn.io/postreceive" || true
