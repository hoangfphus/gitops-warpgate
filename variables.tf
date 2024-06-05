variable "wg_admin_user" {
  description = "Administrator user of warpgate"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "wg_admin_password" {
  description = "Administrator password of warpgate"
  type        = string
  default     = null
  sensitive   = true
}

variable "wg_expose_port" {
  description = "port expose of wg"
  type        = number
  default     = 9876
  sensitive   = true
}

variable "wg_server_host" {
  description = "ip of server host wg"
  type        = string
  default     = null
  sensitive   = true
}