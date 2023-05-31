terraform {
  required_version = ">= 1.4.6"

  required_providers {
    aws        = ">= 4.38.0"
    local      = ">= 2.2.3"
    random     = ">= 3.4.3"
    kubernetes = ">= 2.15.0"
  }
}
