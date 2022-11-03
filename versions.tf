terraform {
  required_version = "~> 1.3.4"

  required_providers {
    aws        = "~> 4.37.0"
    local      = "~> 1.4.0"
    random     = "~> 2.1.0"
    kubernetes = "~> 2.15.0"
  }
}
