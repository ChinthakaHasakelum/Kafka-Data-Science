#!/bin/bash

cat repos.txt | while read repo;
do
  git clone git@github.com:pearsontechnology/${repo}.git
  if [ ${repo} != "bitesize-integration" ] ; then
    if [ ${repo} != "bitesize-environments" ] ; then
        echo "copying makefile to $repo"
        cp ../Makefile ${repo}
cat >${repo}/README.md << EOF
## ${repo}

[![Build Status](https://travis-ci.com/pearsontechnology/${repo}.svg?token=AGpoZrvw2gvbstQQZ3Uc&branch=master)](https://travis-ci.com/pearsontechnology/${repo})
EOF
        cat ../README_MODULE.md >> ${repo}/README.md
        cp ../module/recv_msg.py ${repo}/module
    fi
  fi
  cp ../.gitignore ${repo}
  cp ../.travis.yml ${repo}
  cp ../PULL_REQUEST_TEMPLATE.md ${repo}
  mkdir -p ${repo}/travis
  cp travis_rw_key.sh ${repo}/travis
  cp -a after_success ${repo}/travis
  cp -a before_install ${repo}/travis
  cp -a install ${repo}/travis
  cp -a script ${repo}/travis
  cp -a ../test ${repo}
  rm ${repo}/test/unit/spec/example_asg_spec.rb
  cp ../test/dev.env ${repo}/test
  # (cd ${repo}/travis && ./travis_rw_key.sh) # Uncomment to run after rotating travis_rw_key in SSM
  (cd ${repo} && git add . && git commit . -m "update from terraform-template" && git push)
done

rm -fr terraform-*
rm -fr bitesize-integration
rm -fr bitesize-environments
