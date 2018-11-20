# **Change Log**

## [Unreleased]

### Changed
- Use the 'BITE-2387-fix-tests' branch of bitesize-integration due to errors described in https://agile-jira.pearson.com/browse/BITE-2387 .

## [v1.0.70] - 2018-03-12

### Changed
- Run all tests, not just the test/kubernetes subfolder, to fulfill https://agile-jira.pearson.com/browse/BITE-2192 .

## [v1.0.65] - 2018-03-07

### Changed
- Push logs to S3 bucket. https://agile-jira.pearson.com/browse/BITE-2330

## [v1.0.64] - 2018-03-07

### Changed
- Make sure unit tests do not try to run when there is no module folder (no "unit" to test) to get builds for bitesize-integration and bitesize-environments. BITE-2329.

## [v1.0.62] - 2018-03-06

### Changed
- Improved destroy_int_env to handle terragrunt failing on AWS timing (make sure to always clean up the environment) (BITE-2329).

## [v1.0.61] - 2018-03-02

### Changed
- Make sure we only run manage-env if the environment does not already exist (if we are re-running the create_int_env stage, the environment will already exist in the Travis cache).
- Follow-up for BITE-2329 .

## [v1.0.56] - 2018-03-02

### Added
- Isolate travis build steps in travis.yml with stages per BITE-2329 .
- Third CIDR to inbound_whitelist to match https://github.com/pearsontechnology/bitesize-environments/blob/master/manage-env.py per https://agile-jira.pearson.com/browse/BITE-2194.

## [v1.0.51] - 2018-02-20

### Added
- About 50 seconds wasn't enough time waiting for vault (https://travis-ci.com/pearsontechnology/terraform-prometheus/builds/66355053). Just wait longer. Try to get https://github.com/pearsontechnology/terraform-prometheus/pull/24 and BITE-2163 moving along.

## [v1.0.49] - 2018-02-19

### Added
- Updated dependencies.sh and test.sh to accommodate bitesize-integration in specific (and begin to be generally friendly towards bitesize-environments) for BITE-2192.

## [v1.0.34] - 2018-01-24

### Added
- Lines to .gitignore build and test residue to avoid git accidentally adding temporary files from local tests (first added as a part of BITE-2039).

## [v1.0.21] - 2018-01-18

### Added
- Unit tests and the scripts with which to run them per https://agile-jira.pearson.com/browse/BITE-2115

### Changed
- test.sh handling of integration tests - to use environment variables instead of a clobbered config.yaml

