terraform {
  required_providers {
    warpgate = {
      source  = "hoangfphus/warpgate"
      version = "0.3.6"
    }
  }
  backend "s3" {}
}

provider "warpgate" {
  host                 = var.wg_server_host
  port                 = var.wg_expose_port
  password             = var.wg_admin_password
  username             = var.wg_admin_user
  insecure_skip_verify = true
}