# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog], and this project adheres to
[Semantic Versioning].

[Keep a Changelog]: https://keepachangelog.com/en/1.0.0/
[Semantic Versioning]: https://semver.org/spec/v2.0.0.html

## [Unreleased]

### Added

- `stack_master validate` checks for missing parameter values ([#323]).

- `stack_master apply` prints names of parameters with missing values
  ([#322]).

### Fixed

- Error assuming role when default aws region not configured in the
  environment ([#324])

[Unreleased]: https://github.com/envato/stack_master/compare/v2.3.0...HEAD
[#322]: https://github.com/envato/stack_master/pull/322
[#323]: https://github.com/envato/stack_master/pull/323
[#324]: https://github.com/envato/stack_master/pull/324

## [2.3.0] - 2020-03-19

### Added

- Print backtrace when given the `--trace` option, for in-process rescued
  errors ([#319]). `StackMaster::TemplateCompiler::TemplateCompilationFailed`
  and `Aws::CloudFormation::Errors::ServiceError` are two such errors.

### Changed

- Load fewer Ruby files: remove several ActiveSupport core extensions and
  Rubygems `require`s ([#318]).

- When a stack name includes a dash (`-`), the corresponding parameter files
  can have either dash, or underscore (`_`) in the filename ([#321]).
  `stack_master init` will use filenames that match the provided stack name.

### Fixed

- `stack_master apply` prints list of parameter file locations if no stack
  parameters files found ([#316]).

- `stack_master apply` exits with status `1` if there are missing stack
  parameters ([#317]).

- Don't print unreadable error backtrace on template compilation errors
  ([#319]).

[2.3.0]: https://github.com/envato/stack_master/compare/v2.2.0...v2.3.0
[#316]: https://github.com/envato/stack_master/pull/316
[#317]: https://github.com/envato/stack_master/pull/317
[#318]: https://github.com/envato/stack_master/pull/318
[#319]: https://github.com/envato/stack_master/pull/319
[#321]: https://github.com/envato/stack_master/pull/321

## [2.2.0]

### Changed

- Exit status is now managed by the `StackMaster::CLI` class rather than the
  `stack_master` binstub ([#310]). The Cucumber test suite can now accurately
  validate the exit status of each command line invocation.

- Unpin and use the latest release of the `commander` gem ([#314]). This
  latest release includes fixes for the global option parsing defect reported
  in [#248].

- Speed up CI: Only run one build job on macOS ([#315]).

- Add CAPABILITY_AUTO_EXPAND to support macros ([#312]).

### Fixed

- `stack_master --version` now returns an exit status `0` ([#310]).

- `delete`, `outputs`, and `resources` commands now exit with a status `1` if
  the specified stack is not in AWS ([#313]).

- The `delete` command now exits with status `1` if using a disallowed AWS
  account ([#313]).

[2.2.0]: https://github.com/envato/stack_master/compare/v2.1.0...v2.2.0
[#248]: https://github.com/envato/stack_master/issues/248
[#310]: https://github.com/envato/stack_master/pull/310
[#312]: https://github.com/envato/stack_master/pull/312
[#313]: https://github.com/envato/stack_master/pull/313
[#314]: https://github.com/envato/stack_master/pull/314
[#315]: https://github.com/envato/stack_master/pull/315

## [2.1.0] - 2020-03-06

### Added

- `stack_master tidy` command ([#305]). This provides a way to identify unused
  parameter files or templates.

### Changed

- Updated README to be explicit about using underscores in parameter file
  names ([#306]).

- Restrict `sparkle_formation` to version 3 ([#307]).

- Build one gem for all Platforms ([#309]). This includes adding the `diff-lcs`
  gem as dependency. Previously, this was only a dependency for the Windows
  release.

[2.1.0]: https://github.com/envato/stack_master/compare/v2.0.1...v2.1.0
[#305]: https://github.com/envato/stack_master/pull/305
[#306]: https://github.com/envato/stack_master/pull/306
[#307]: https://github.com/envato/stack_master/pull/307
[#309]: https://github.com/envato/stack_master/pull/309

## [2.0.1] - 2020-01-22

### Changed

- Pin cfndsl to below 1.0

[2.0.1]: https://github.com/envato/stack_master/compare/v2.0.0...v2.0.1

## [2.0.0] - 2020-01-22

### Added

- Test against Ruby 2.7, ([#296]).

### Changed

- Some method calls changed to be explicit about converting hashes to keyword
  arguments. Resolves warnings raised by Ruby 2.7, ([#296]).
- Bump the minimum required Ruby version from 2.1 to 2.4 ([#297]).

### Removed

- Extracted GPG secret parameter resolving to a separate gem. Please add
  [stack_master-gpg_parameter_resolver] to your bundle to continue using this
  functionality ([#295]).

[2.0.0]: https://github.com/envato/stack_master/compare/v1.18.0...v2.0.0
[stack_master-gpg_parameter_resolver]: https://rubygems.org/gems/stack_master-gpg_parameter_resolver
[#295]: https://github.com/envato/stack_master/pull/295
[#296]: https://github.com/envato/stack_master/pull/296
[#297]: https://github.com/envato/stack_master/pull/297

## [1.18.0] - 2019-12-23

### Added

- A change log document ([#293]).

- Project metadata to the gemspec ([#293]).

- Enable cross-account parameter resolving ([#292])

### Changed

- Not updating RubyGems and Bundler in CI ([#294])

- Drop ruby 2.3 support in CI ([#294])

[1.18.0]: https://github.com/envato/stack_master/compare/v1.17.1...v1.18.0
[#292]: https://github.com/envato/stack_master/pull/292
[#293]: https://github.com/envato/stack_master/pull/293
[#294]: https://github.com/envato/stack_master/pull/294

## [1.17.1] - 2019-10-3

### Fixed

- Fix error when the EJSON secret key can't be found ([#291]).

[1.17.1]: https://github.com/envato/stack_master/compare/v1.17.0...v1.17.1
[#291]: https://github.com/envato/stack_master/pull/291

## [1.17.0] - 2019-8-20

### Changed

- Move `sparkle_pack_template` from the stack definition to
  `compiler_options` ([#289]).

  ```yaml
  stacks:
    us-east-1:
      sparkle_pack_test:
        template: template_with_dynamic_from_pack
        compiler: sparkle_formation
        compiler_options:
          sparkle_pack_template: true
          sparkle_packs:
            - my_sparkle_pack
  ```

- Changed `TemplateCompiler` interface to take the template directory and the
  template (name), instead of the directory and the full path ([#289]).

### Fixed

- Improve `SparkleFormation` compiler specs. They were very brittle. Changed
  them to run SparkleFormation without stubbing it out ([#289]).

[1.17.0]: https://github.com/envato/stack_master/compare/v1.16.0...v1.17.0
[#289]: https://github.com/envato/stack_master/pull/289

## [1.16.0] - 2019-8-16

### Added

- Enable reading templates from Sparkle packs ([#286]).

[1.16.0]: https://github.com/envato/stack_master/compare/v1.15.0...v1.16.0
[#286]: https://github.com/envato/stack_master/pull/286

## [1.15.0] - 2019-8-9

### Added

- Add a parameter resolver for EJSON files ([#264]).

  ```yaml
  my_param:
    ejson: "my_secret"
  ```

### Fixed

- Use the `hashdiff`'s v1 namespace: `Hashdiff` ([#285]).

[1.15.0]: https://github.com/envato/stack_master/compare/v1.14.0...v1.15.0
[#264]: https://github.com/envato/stack_master/pull/264
[#285]: https://github.com/envato/stack_master/pull/285

## [1.14.0] - 2019-7-3

### Added

- Add ability to restrict in which AWS accounts a stack can be applied in ([#283]).

### Fixed

- `stack_master lint` provides helpful instruction if `cfn-lint` is not
  installed ([#281]).

- Fixed Windows build Docker image ([#284]).

[1.14.0]: https://github.com/envato/stack_master/compare/v1.13.1...v1.14.0
[#281]: https://github.com/envato/stack_master/pull/281
[#283]: https://github.com/envato/stack_master/pull/283
[#284]: https://github.com/envato/stack_master/pull/284

## [1.13.1] - 2019-3-20

### Fixed

- `stack_master apply` exits with status code 0 when there are no changes ([#280]).

- `stack_master validate` exit status code reflects validity of stack ([#280]).

[1.13.1]: https://github.com/envato/stack_master/compare/v1.13.0...v1.13.1
[#280]: https://github.com/envato/stack_master/pull/280

## [1.13.0] - 2019-2-17

### Fixed

- Return non-zero exit status when command fails ([#276]).

[1.13.0]: https://github.com/envato/stack_master/compare/v1.12.0...v1.13.0
[#276]: https://github.com/envato/stack_master/pull/276

## [1.12.0] - 2019-1-11

### Added

- Add `--quiet` command line option to surpresses stack event output ([#272]).

### Changed

- Add Ruby 2.6 to the CI matrix, and remove 2.1 and 2.2 ([#269]).

- Test against the latest versions of Rubygems and Bundler in the CI build ([#271]).

### Fixed

- Output helpful error when container parameter provider finds no images
  matching the provided tag ([#258]).

- Always convert underscores to hyphen in stack name in `stack_master delete`
  command ([#263]).

[1.12.0]: https://github.com/envato/stack_master/compare/v1.11.1...v1.12.0
[#258]: https://github.com/envato/stack_master/pull/258
[#263]: https://github.com/envato/stack_master/pull/263
[#269]: https://github.com/envato/stack_master/pull/269
[#271]: https://github.com/envato/stack_master/pull/271
[#272]: https://github.com/envato/stack_master/pull/272

## [1.11.1] - 2018-10-16

### Fixed

- Display changeset before asking for confirmation ([#254]).

[1.11.1]: https://github.com/envato/stack_master/compare/v1.11.0...v1.11.1
[#254]: https://github.com/envato/stack_master/pull/254

## [1.11.0] - 2018-10-9

### Added

- Add `--yes-param` option for single-param update auto-confim on `apply` ([#252]).

[1.11.0]: https://github.com/envato/stack_master/compare/v1.10.0...v1.11.0
[#252]: https://github.com/envato/stack_master/pull/252

## [1.10.0] - 2018-9-14

### Added

- Pass compile-time parameters through to the [cfndsl] template compiler ([#219]).

[1.10.0]: https://github.com/envato/stack_master/compare/v1.9.1...v1.10.0
[cfndsl]: https://github.com/cfndsl/cfndsl
[#219]: https://github.com/envato/stack_master/pull/219

## [1.9.1] - 2018-9-3

### Fixed

- Improve error reporting: print backtrace when template compilation fails ([#251]).

[1.9.1]: https://github.com/envato/stack_master/compare/v1.9.0...v1.9.1
[#251]: https://github.com/envato/stack_master/pull/251

## [1.9.0] - 2018-8-24

### Added

- Add parameter resolver for identifying the latest container image in an AWS
  ECR ([#250]).

  ```yaml
  container_image_id:
    latest_container:
      repository_name: "nginx"
      registry_id: "012345678910"
      region: "us-east-1"
      tag: "latest"
  ```

[1.9.0]: https://github.com/envato/stack_master/compare/v1.8.2...v1.9.0
[#250]: https://github.com/envato/stack_master/pull/250

## [1.8.2] - 2018-8-24

### Fixed

- Fix `stack_master init` problem by including `stacktemplates` directory in
  the gem package ([#247]).

[1.8.2]: https://github.com/envato/stack_master/compare/v1.8.1...v1.8.2
[#247]: https://github.com/envato/stack_master/pull/247

## [1.8.1] - 2018-8-17

### Fixed

- Pin `commander` gem to `<= 4.4.5` to fix defect in the parsing of global
  options ([#249]).

[1.8.1]: https://github.com/envato/stack_master/compare/v1.8.0...v1.8.1
[#249]: https://github.com/envato/stack_master/pull/249

## [1.8.0] - 2018-7-5

### Added

- Add parameter resolver for AWS ACM certificates ([#227]).

  ```yaml
  cert:
    acm_certificate: "www.example.com"
  ```

- Add `lint` and `compile` sub commands ([#245]).

[1.8.0]: https://github.com/envato/stack_master/compare/v1.7.2...v1.8.0
[#227]: https://github.com/envato/stack_master/pull/227
[#245]: https://github.com/envato/stack_master/pull/245

## [1.7.2] - 2018-7-5

### Fixed

- Fix `STDIN#getch` error on Windows ([#241]).

- Display informative message if `stack_master.yml` cannot be parsed ([#243]).

[1.7.2]: https://github.com/envato/stack_master/compare/v1.7.1...v1.7.2
[#241]: https://github.com/envato/stack_master/pull/241
[#243]: https://github.com/envato/stack_master/pull/243

## [1.7.1] - 2018-6-8

### Fixed

- Display informative message if the stack has `REVIEW_IN_PROGRESS` status ([#233]).

- Fix diffing on Windows by adding a runtime dependency on the `diff-lcs` gem ([#240]).

[1.7.1]: https://github.com/envato/stack_master/compare/v1.7.0...v1.7.1
[#233]: https://github.com/envato/stack_master/pull/233
[#240]: https://github.com/envato/stack_master/pull/240

## [1.7.0] - 2018-5-15

### Added

- Add 1Password parameter resolver ([#220]).

  ```yaml
  database_password:
    one_password:
      title: "production database"
      vault: "Shared"
      type: "password"
  ```

- Add convenience scripts for building Windows release ([#229], [#230]).

[1.7.0]: https://github.com/envato/stack_master/compare/v1.6.0...v1.7.0
[#220]: https://github.com/envato/stack_master/pull/220
[#229]: https://github.com/envato/stack_master/pull/229
[#230]: https://github.com/envato/stack_master/pull/230

## [1.6.0] - 2018-5-11

### Added

- Add release for Windows ([#228]).

  ```sh
  gem install stack_master --platform x86-mingw32
  ```

[1.6.0]: https://github.com/envato/stack_master/compare/v1.5.0...v1.6.0
[#228]: https://github.com/envato/stack_master/pull/228

## [1.5.0] - 2018-5-7

### Changed

- Include the stack name in the AWS Cloudformation changeset name ([#224]).

[1.5.0]: https://github.com/envato/stack_master/compare/v1.4.0...v1.5.0
[#224]: https://github.com/envato/stack_master/pull/224

## [1.4.0] - 2018-4-19

### Added

- Add a code of conduct ([#212]).

### Changed

- Move from AWS SDK v2 to v3 ([#222]).

### Fixed

- Ensure `SecureRandom` has been required ([#200]).

- Fix error when the `oj` gem is installed. Configure `multi_json` to use the
  `json` gem ([#215]).

- Readme clean up ([#218]).

[1.4.0]: https://github.com/envato/stack_master/compare/v1.3.1...v1.4.0
[#200]: https://github.com/envato/stack_master/pull/200
[#212]: https://github.com/envato/stack_master/pull/212
[#215]: https://github.com/envato/stack_master/pull/215
[#218]: https://github.com/envato/stack_master/pull/218
[#222]: https://github.com/envato/stack_master/pull/222

## [1.3.1] - 2018-3-18

### Fixed

- Support China-region S3 URLs ([#217]).

[1.3.1]: https://github.com/envato/stack_master/compare/v1.3.0...v1.3.1
[#217]: https://github.com/envato/stack_master/pull/217

## [1.3.0] - 2018-3-1

### Added

- Support loading Sparkle Packs ([#216]).

[1.3.0]: https://github.com/envato/stack_master/compare/v1.2.1...v1.3.0
[#216]: https://github.com/envato/stack_master/pull/216

## [1.2.1] - 2018-2-23

### Added

- Add an 'AWS SSM Parameter Store' parameter resolver ([#211]).

  ```yaml
  stack_parameter:
    parameter_store: "ssm_name"
  ```

[1.2.1]: https://github.com/envato/stack_master/compare/v1.1.0...v1.2.1
[#211]: https://github.com/envato/stack_master/pull/211

## [1.1.0] - 2018-2-21

### Added

- Support `yaml` file extension for parameter files. Both `.yml` and `.yaml`
  now work ([#203]).

- Test against Ruby 2.5 ([#206]) in CI build.

- Add license, version and build status badges to the readme ([#208]).

- Add an environment parameter resolver ([#209]).

  ```yaml
  db_username:
    env: "DB_USERNAME"
  ```

- Make output more readable: separate proposed change set with whitespace and
  border ([#210]).

[1.1.0]: https://github.com/envato/stack_master/compare/v1.0.1...v1.1.0
[#203]: https://github.com/envato/stack_master/pull/203
[#206]: https://github.com/envato/stack_master/pull/206
[#208]: https://github.com/envato/stack_master/pull/208
[#209]: https://github.com/envato/stack_master/pull/209
[#210]: https://github.com/envato/stack_master/pull/210

## [1.0.1] - 2017-12-15

### Fixed

- Don't leave behind failed changesets ([#202]).

[1.0.1]: https://github.com/envato/stack_master/compare/v1.0.0...v1.0.1
[#202]: https://github.com/envato/stack_master/pull/202

## [1.0.0] - 2017-12-11

### Added

- First stable release!

[1.0.0]: https://github.com/envato/stack_master/releases/tag/v1.0.0
