resource "azurerm_private_dns_resolver" "this" {
  name                = "pdnsr-example"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  virtual_network_id  = azurerm_virtual_network.this.id
}


resource "azurerm_private_dns_resolver_inbound_endpoint" "this" {
  name                    = "drie-example"
  private_dns_resolver_id = azurerm_private_dns_resolver.this.id
  location                = azurerm_private_dns_resolver.this.location
  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = azurerm_subnet.dns.id
  }
}
