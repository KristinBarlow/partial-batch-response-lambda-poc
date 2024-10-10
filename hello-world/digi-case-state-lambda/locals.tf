locals {
  common_tags = {
    Environment = var.aws-region-id
    Owner       = "ESC"
    Cluster     = "Global"
    Product     = "Digi"
    Branch      = var.lambda-version-branch-name
    Version     = var.lambda-version-hash
  }
}
