variable "client_id" {
  type = string
}

variable "client_secret" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "location" {
  type    = string
  default = "North Europe"
}

variable "aad_audience" {
  type    = string
  default = "<Azure VPN Enterprise Application ID"
}
