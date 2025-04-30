include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/identity-center"
}

inputs = {
  instance_arn = "arn:aws:sso:::instance/ssoins-7230a93085e14102" 
  identity_store_id = "d-9b6761f4ac"
  groups = {
    "developer-deploy" = {
      description = "for deploy"
    }
    "developer-morning-letter" = {
      description = "for Morning Letter"
    }
  }
} 