resource "azurerm_private_dns_zone" "this" {
  name                = "myownprivatedns.com"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_a_record" "test" {
  name                = "test"
  zone_name           = azurerm_private_dns_zone.this.name
  resource_group_name = azurerm_resource_group.this.name
  ttl                 = 300
  records             = ["10.0.180.17"]
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "pdns-vnet-core-link"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = azurerm_virtual_network.this.id
}
