locals {
  wg_roles        = yamldecode(file("data/roles"))
  wg_users        = yamldecode(file("data/users"))
  wg_http_targets = yamldecode(file("data/http_targets"))
}