terraform {
  required_version = "~> 1.3.4"

  required_providers {
    aws        = "~> 4.37.0"
    local      = "~> 2.2.3"
    random     = "~> 3.4.3"
    kubernetes = "~> 2.15.0"
  }
}
