# Changelog

## [3.2.2](https://github.com/dryvist/terraform-runs-on/compare/v3.2.1...v3.2.2) (2026-06-22)


### Bug Fixes

* use generic DOPPLER_TOKEN secret name in CI/docs ([#89](https://github.com/dryvist/terraform-runs-on/issues/89)) ([5c8e6d1](https://github.com/dryvist/terraform-runs-on/commit/5c8e6d1c679d0d7a0f9996502a48d7891e150d8e))

## [3.2.1](https://github.com/dryvist/terraform-runs-on/compare/v3.2.0...v3.2.1) (2026-06-12)


### Bug Fixes

* **ci:** repoint osv-scan to dryvist/.github hub ([#85](https://github.com/dryvist/terraform-runs-on/issues/85)) ([785997e](https://github.com/dryvist/terraform-runs-on/commit/785997ea20efc4966cd85d672dded98be939d424))

## [3.2.0](https://github.com/dryvist/terraform-runs-on/compare/v3.1.0...v3.2.0) (2026-06-01)


### Features

* adopt nix-devenv terraform pre-commit profile ([#80](https://github.com/dryvist/terraform-runs-on/issues/80)) ([670831d](https://github.com/dryvist/terraform-runs-on/commit/670831d2b5f8bf1f7fc1cd3e4c11ff2c5e835206))


### Bug Fixes

* **ci:** repoint release-please caller to org-native reusable workflow ([#82](https://github.com/dryvist/terraform-runs-on/issues/82)) ([1825730](https://github.com/dryvist/terraform-runs-on/commit/1825730a37e66e0a7d9b56a636306dc35f23c645))
* **iac:** grant WAFv2 IAM permissions to the CI deploy role ([#79](https://github.com/dryvist/terraform-runs-on/issues/79)) ([9569b6a](https://github.com/dryvist/terraform-runs-on/commit/9569b6aae3e099cb342a9ea67326e9230aafbfe3))
* **iac:** retarget CI OIDC trust, RunsOn org, and reusable workflows after dryvist migration ([#78](https://github.com/dryvist/terraform-runs-on/issues/78)) ([1bc1a83](https://github.com/dryvist/terraform-runs-on/commit/1bc1a83a061e66b38598013144725921670abd6c))

## [3.1.0](https://github.com/JacobPEvans/terraform-runs-on/compare/v3.0.0...v3.1.0) (2026-05-19)


### Features

* add RunsOn self-hosted GitHub Actions runners infrastructure ([5450559](https://github.com/JacobPEvans/terraform-runs-on/commit/5450559bc26c5d036a539ee257bcff2b8814fdb7))
* **ci:** add scheduled fleet canary with healthchecks.io ping ([#51](https://github.com/JacobPEvans/terraform-runs-on/issues/51)) ([a5c7db9](https://github.com/JacobPEvans/terraform-runs-on/commit/a5c7db97f2f429a18381e4505d189a887b7fccb0))
* **iac:** WAF, admin gating, Bedrock + v3 migration cleanup ([#64](https://github.com/JacobPEvans/terraform-runs-on/issues/64)) ([687512b](https://github.com/JacobPEvans/terraform-runs-on/commit/687512bf426badaf9ff8dcf8f0a93c84eb8b7c6a))


### Bug Fixes

* batch terraform and terragrunt dependency updates ([#46](https://github.com/JacobPEvans/terraform-runs-on/issues/46)) ([ff528b5](https://github.com/JacobPEvans/terraform-runs-on/commit/ff528b5af0e752494d052b5eef7e4df1a4968acc))
* bootstrap infrastructure with correct naming, profile, and secrets ([8a0f336](https://github.com/JacobPEvans/terraform-runs-on/commit/8a0f33631013efa258797e4f619f9d54bd6f7ec0)), closes [#5](https://github.com/JacobPEvans/terraform-runs-on/issues/5)
* **ci:** add workflow_dispatch trigger as manual escape valve ([#50](https://github.com/JacobPEvans/terraform-runs-on/issues/50)) ([088bfb8](https://github.com/JacobPEvans/terraform-runs-on/commit/088bfb8ee7fb0354cfa71ea3ed6a4b8feb7637f7))
* **ci:** fetch OIDC role ARN from Doppler at runtime ([#21](https://github.com/JacobPEvans/terraform-runs-on/issues/21)) ([688de09](https://github.com/JacobPEvans/terraform-runs-on/commit/688de092b950db1765a55745415c9695517b1f91))
* **ci:** fetch RUNSON_LICENSE_KEY from Doppler at runtime ([#18](https://github.com/JacobPEvans/terraform-runs-on/issues/18)) ([aaea1ac](https://github.com/JacobPEvans/terraform-runs-on/commit/aaea1ac94e5941beeb1e762c1582e582eeded856))
* **ci:** make smoke-runner healthcheck ping conditional on HC key ([#61](https://github.com/JacobPEvans/terraform-runs-on/issues/61)) ([d10abd9](https://github.com/JacobPEvans/terraform-runs-on/commit/d10abd963d411e2597d8e556a28b5d9a962e257f))
* **ci:** mask AWS account ID and scrub sensitive output across CI/CD ([fd8026f](https://github.com/JacobPEvans/terraform-runs-on/commit/fd8026fd115ea81e72092601fd0146f389e80f4b)), closes [#26](https://github.com/JacobPEvans/terraform-runs-on/issues/26)
* **ci:** remove deprecated app-id secret passthrough ([71d8dcf](https://github.com/JacobPEvans/terraform-runs-on/commit/71d8dcf3b36ea35deded48b7a550f9252a5de129))
* **ci:** upgrade Node 20 actions to Node 24 versions ([#23](https://github.com/JacobPEvans/terraform-runs-on/issues/23)) ([e52aab2](https://github.com/JacobPEvans/terraform-runs-on/commit/e52aab2c1b3555cc09ed558f68194b96a804d5ad))
* correct RunsOn job label syntax to v2 format ([#15](https://github.com/JacobPEvans/terraform-runs-on/issues/15)) ([134e8ea](https://github.com/JacobPEvans/terraform-runs-on/commit/134e8ea985f757e113450294e47223828fffc716))
* **iac:** complete v3 bootstrap — ECS perms, SLR, alerts, ingress output ([#59](https://github.com/JacobPEvans/terraform-runs-on/issues/59)) ([578ceaa](https://github.com/JacobPEvans/terraform-runs-on/commit/578ceaaa6fd08605c3ce941730dbd14783ab4994))
* prepare repo for v3 control plane apply ([#55](https://github.com/JacobPEvans/terraform-runs-on/issues/55)) ([5461b21](https://github.com/JacobPEvans/terraform-runs-on/commit/5461b21f42fa2b1b945eee4647800f5ae6771fb3))
* recompile gh-aw workflows with v0.68.1 ([33fa681](https://github.com/JacobPEvans/terraform-runs-on/commit/33fa681b242d14c771c88070fe37dd56b751e005))
* tighten OIDC policy permissions and update README ([d174bc3](https://github.com/JacobPEvans/terraform-runs-on/commit/d174bc38d8c9407d8463732e5a42abf6ad4b9226)), closes [#9](https://github.com/JacobPEvans/terraform-runs-on/issues/9)
* ungate terraform_* pre-commit hooks ([#48](https://github.com/JacobPEvans/terraform-runs-on/issues/48)) [issue-solver-2026-05-11] ([#49](https://github.com/JacobPEvans/terraform-runs-on/issues/49)) ([a2430e9](https://github.com/JacobPEvans/terraform-runs-on/commit/a2430e93cca23858b2994b060f0f263313190ffc))

## [0.4.0](https://github.com/JacobPEvans/terraform-runs-on/compare/v0.3.4...v0.4.0) (2026-05-19)


### Features

* **iac:** WAF, admin gating, Bedrock + v3 migration cleanup ([#64](https://github.com/JacobPEvans/terraform-runs-on/issues/64)) ([687512b](https://github.com/JacobPEvans/terraform-runs-on/commit/687512bf426badaf9ff8dcf8f0a93c84eb8b7c6a))

## [0.3.4](https://github.com/JacobPEvans/terraform-runs-on/compare/v0.3.3...v0.3.4) (2026-05-15)


### Bug Fixes

* **iac:** complete v3 bootstrap — ECS perms, SLR, alerts, ingress output ([#59](https://github.com/JacobPEvans/terraform-runs-on/issues/59)) ([578ceaa](https://github.com/JacobPEvans/terraform-runs-on/commit/578ceaaa6fd08605c3ce941730dbd14783ab4994))

## [0.3.3](https://github.com/JacobPEvans/terraform-runs-on/compare/v0.3.2...v0.3.3) (2026-05-15)


### Bug Fixes

* **ci:** make smoke-runner healthcheck ping conditional on HC key ([#61](https://github.com/JacobPEvans/terraform-runs-on/issues/61)) ([d10abd9](https://github.com/JacobPEvans/terraform-runs-on/commit/d10abd963d411e2597d8e556a28b5d9a962e257f))

## [0.3.2](https://github.com/JacobPEvans/terraform-runs-on/compare/v0.3.1...v0.3.2) (2026-05-14)


### Bug Fixes

* prepare repo for v3 control plane apply ([#55](https://github.com/JacobPEvans/terraform-runs-on/issues/55)) ([5461b21](https://github.com/JacobPEvans/terraform-runs-on/commit/5461b21f42fa2b1b945eee4647800f5ae6771fb3))

## [0.3.1](https://github.com/JacobPEvans/terraform-runs-on/compare/v0.3.0...v0.3.1) (2026-05-12)


### Bug Fixes

* batch terraform and terragrunt dependency updates ([#46](https://github.com/JacobPEvans/terraform-runs-on/issues/46)) ([ff528b5](https://github.com/JacobPEvans/terraform-runs-on/commit/ff528b5af0e752494d052b5eef7e4df1a4968acc))
* ungate terraform_* pre-commit hooks ([#48](https://github.com/JacobPEvans/terraform-runs-on/issues/48)) [issue-solver-2026-05-11] ([#49](https://github.com/JacobPEvans/terraform-runs-on/issues/49)) ([a2430e9](https://github.com/JacobPEvans/terraform-runs-on/commit/a2430e93cca23858b2994b060f0f263313190ffc))

## [0.3.0](https://github.com/JacobPEvans/terraform-runs-on/compare/v0.2.9...v0.3.0) (2026-05-12)


### Features

* **ci:** add scheduled fleet canary with healthchecks.io ping ([#51](https://github.com/JacobPEvans/terraform-runs-on/issues/51)) ([a5c7db9](https://github.com/JacobPEvans/terraform-runs-on/commit/a5c7db97f2f429a18381e4505d189a887b7fccb0))


### Bug Fixes

* **ci:** add workflow_dispatch trigger as manual escape valve ([#50](https://github.com/JacobPEvans/terraform-runs-on/issues/50)) ([088bfb8](https://github.com/JacobPEvans/terraform-runs-on/commit/088bfb8ee7fb0354cfa71ea3ed6a4b8feb7637f7))

## [0.2.9](https://github.com/JacobPEvans/terraform-runs-on/compare/v0.2.8...v0.2.9) (2026-05-03)


### Bug Fixes

* **ci:** remove deprecated app-id secret passthrough ([71d8dcf](https://github.com/JacobPEvans/terraform-runs-on/commit/71d8dcf3b36ea35deded48b7a550f9252a5de129))

## [0.2.8](https://github.com/JacobPEvans/terraform-runs-on/compare/v0.2.7...v0.2.8) (2026-04-25)


### Bug Fixes

* **ci:** mask AWS account ID and scrub sensitive output across CI/CD ([fd8026f](https://github.com/JacobPEvans/terraform-runs-on/commit/fd8026fd115ea81e72092601fd0146f389e80f4b)), closes [#26](https://github.com/JacobPEvans/terraform-runs-on/issues/26)

## [0.2.7](https://github.com/JacobPEvans/terraform-runs-on/compare/v0.2.6...v0.2.7) (2026-04-13)


### Bug Fixes

* recompile gh-aw workflows with v0.68.1 ([33fa681](https://github.com/JacobPEvans/terraform-runs-on/commit/33fa681b242d14c771c88070fe37dd56b751e005))

## [0.2.6](https://github.com/JacobPEvans/terraform-runs-on/compare/v0.2.5...v0.2.6) (2026-04-11)


### Bug Fixes

* **ci:** upgrade Node 20 actions to Node 24 versions ([#23](https://github.com/JacobPEvans/terraform-runs-on/issues/23)) ([e52aab2](https://github.com/JacobPEvans/terraform-runs-on/commit/e52aab2c1b3555cc09ed558f68194b96a804d5ad))

## [0.2.5](https://github.com/JacobPEvans/terraform-runs-on/compare/v0.2.4...v0.2.5) (2026-04-11)


### Bug Fixes

* **ci:** fetch OIDC role ARN from Doppler at runtime ([#21](https://github.com/JacobPEvans/terraform-runs-on/issues/21)) ([688de09](https://github.com/JacobPEvans/terraform-runs-on/commit/688de092b950db1765a55745415c9695517b1f91))

## [0.2.4](https://github.com/JacobPEvans/terraform-runs-on/compare/v0.2.3...v0.2.4) (2026-04-10)


### Bug Fixes

* **ci:** fetch RUNSON_LICENSE_KEY from Doppler at runtime ([#18](https://github.com/JacobPEvans/terraform-runs-on/issues/18)) ([aaea1ac](https://github.com/JacobPEvans/terraform-runs-on/commit/aaea1ac94e5941beeb1e762c1582e582eeded856))

## [0.2.3](https://github.com/JacobPEvans/terraform-runs-on/compare/v0.2.2...v0.2.3) (2026-04-10)


### Bug Fixes

* correct RunsOn job label syntax to v2 format ([#15](https://github.com/JacobPEvans/terraform-runs-on/issues/15)) ([134e8ea](https://github.com/JacobPEvans/terraform-runs-on/commit/134e8ea985f757e113450294e47223828fffc716))

## [0.2.2](https://github.com/JacobPEvans/terraform-runs-on/compare/v0.2.1...v0.2.2) (2026-03-26)


### Bug Fixes

* tighten OIDC policy permissions and update README ([d174bc3](https://github.com/JacobPEvans/terraform-runs-on/commit/d174bc38d8c9407d8463732e5a42abf6ad4b9226)), closes [#9](https://github.com/JacobPEvans/terraform-runs-on/issues/9)

## [0.2.1](https://github.com/JacobPEvans/terraform-runs-on/compare/v0.2.0...v0.2.1) (2026-03-26)


### Bug Fixes

* bootstrap infrastructure with correct naming, profile, and secrets ([8a0f336](https://github.com/JacobPEvans/terraform-runs-on/commit/8a0f33631013efa258797e4f619f9d54bd6f7ec0)), closes [#5](https://github.com/JacobPEvans/terraform-runs-on/issues/5)

## [0.2.0](https://github.com/JacobPEvans/terraform-runs-on/compare/v0.1.0...v0.2.0) (2026-03-23)


### Features

* add RunsOn self-hosted GitHub Actions runners infrastructure ([5450559](https://github.com/JacobPEvans/terraform-runs-on/commit/5450559bc26c5d036a539ee257bcff2b8814fdb7))

## Changelog
