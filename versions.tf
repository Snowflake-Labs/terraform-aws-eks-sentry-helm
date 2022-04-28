terraform {
  required_version = ">= 1.1.7"

  required_providers {
    aws        = ">= 4.2.0"
    local      = ">= 1.4"
    random     = ">= 2.1"
    kubernetes = ">= 2.0"
  }
}
