# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_wan
resource "azurerm_virtual_wan" "this" {
  name                   = "vwan-example"
  resource_group_name    = azurerm_resource_group.this.name
  location               = "northeurope"
  type                   = "Standard"
  disable_vpn_encryption = false
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/vpn_server_configuration
resource "azurerm_vpn_server_configuration" "this" {
  name                     = "vsc-example"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = var.location
  vpn_authentication_types = ["AAD"]
  vpn_protocols            = ["OpenVPN"]

  azure_active_directory_authentication {
    tenant   = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}"
    audience = var.aad_audience
    issuer   = "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/"
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_hub
resource "azurerm_virtual_hub" "this" {
  name                = "vhub-example"
  resource_group_name = azurerm_resource_group.this.name
  location            = "northeurope"
  virtual_wan_id      = azurerm_virtual_wan.this.id
  address_prefix      = "10.111.0.0/24"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/point_to_site_vpn_gateway
resource "azurerm_point_to_site_vpn_gateway" "this" {
  name                        = "vgat-example"
  resource_group_name         = azurerm_resource_group.this.name
  location                    = "northeurope"
  virtual_hub_id              = azurerm_virtual_hub.this.id
  vpn_server_configuration_id = azurerm_vpn_server_configuration.this.id
  scale_unit                  = 1

  dns_servers = [
    azurerm_private_dns_resolver_inbound_endpoint.this.ip_configurations[0].private_ip_address
  ]

  connection_configuration {
    name                      = "vpnconfig-example"
    internet_security_enabled = true

    vpn_client_address_pool {
      address_prefixes = [
        "10.111.1.0/24"
      ]
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_hub_connection
resource "azurerm_virtual_hub_connection" "core" {
  name                      = "vhubconn-core-example"
  virtual_hub_id            = azurerm_virtual_hub.this.id
  remote_virtual_network_id = azurerm_virtual_network.this.id

}

# https://registry.terraform.io/providers/hashicorp/Azurerm/latest/docs/resources/virtual_hub_routing_intent
resource "azurerm_virtual_hub_routing_intent" "this" {
  name           = "RoutingIntent"
  virtual_hub_id = azurerm_virtual_hub.this.id

  routing_policy {
    name         = "InternetTrafficPolicy"
    destinations = ["Internet"]
    next_hop     = azurerm_firewall.this.id
  }
  routing_policy {
    name         = "PrivateTrafficPolicy"
    destinations = ["PrivateTraffic"]
    next_hop     = azurerm_firewall.this.id
  }
}
