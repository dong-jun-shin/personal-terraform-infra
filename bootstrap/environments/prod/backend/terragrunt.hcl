include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/backend"
}

inputs = {
  keypair_name  = "morning-letter-dev-keypair" # SSH Key Pair
}
