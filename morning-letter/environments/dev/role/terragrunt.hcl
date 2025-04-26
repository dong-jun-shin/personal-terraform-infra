include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "dev" {
  path = find_in_parent_folders("dev.hcl")
}

dependency "backend" {
  config_path = "../../../bootstrap/backend"
}

terraform {
  source = "../../../modules/role"
}

inputs = {
  env_object_arn = "${dependency.backend.outputs.infra_files_bucket_arn}/morning-letter-env/.env.development"
  github_pat_s3_object_arn = "${dependency.backend.outputs.infra_files_bucket_arn}/morning-letter-infra/deployments/github_token_docker_registry.env"
  artifact_s3_object_arn = "${dependency.backend.outputs.infra_files_bucket_arn}/morning-letter-infra/deployments/morning-letter-dev-deploy-artifacts-latest.tgz"
} 