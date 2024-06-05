resource "warpgate_role" "list_role" {
  for_each = { for role in local.wg_roles : role => role }
  name     = each.key
}

resource "warpgate_user" "list_user_with_credential" {
  for_each = { for user in local.wg_users : user.username => user }
  username = each.value.username
  credentials = [{
    kind     = each.value.credentials.kind
    email    = each.value.credentials.email
    provider = each.value.credentials.provider
  }]
}

resource "warpgate_user_roles" "list_user_with_roles" {
  for_each = {
    for user in local.wg_users : user.username => user
  }
  id = warpgate_user.list_user_with_credential[each.key].id
  role_ids = [
    for role_name in each.value.roles : contains(keys(warpgate_role.list_role), role_name) ? warpgate_role.list_role[role_name].id : null
  ]
}

resource "warpgate_http_target" "list_http_targets_with_options" {
  for_each = {
    for http_target in local.wg_http_targets : http_target.name => http_target
  }
  name = format("%s%s", each.value.name, ".warpgate.example.vn")
  options = {
    url = each.value.options.url
    tls = {
      mode   = each.value.options.tls.mode
      verify = each.value.options.tls.verify
    }
    headers = can(each.value.options.headers) ? each.value.options.headers : null
    #external_host = can(each.value.options.external_host) ? each.value.options.external_host : null
    external_host = format("%s%s", each.value.name, ".warpgate.example.vn") #this line can be better
  }
}

resource "warpgate_target_roles" "list_http_targets_with_roles" {
  for_each = {
    for http_target in local.wg_http_targets : http_target.name => http_target
  }
  id = warpgate_http_target.list_http_targets_with_options[each.key].id
  role_ids = [
    for role_name in each.value.allow_access : contains(keys(warpgate_role.list_role), role_name) ? warpgate_role.list_role[role_name].id : null
  ]
}