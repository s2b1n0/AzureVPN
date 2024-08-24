# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy
resource "azurerm_firewall_policy" "this" {
  name                     = "afwp-example"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = "northeurope"
  sku                      = "Standard"
  threat_intelligence_mode = "Alert"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy_rule_collection_group
resource "azurerm_firewall_policy_rule_collection_group" "this" {
  name               = "rcg-example"
  firewall_policy_id = azurerm_firewall_policy.this.id
  priority           = 100

  application_rule_collection {
    name     = "DenyMaliciousWebCategories"
    action   = "Deny"
    priority = 200
    rule {
      name        = "Deny-Malicious-Web-Categories"
      description = "Deny access to malicious web categories"
      protocols {
        type = "Https"
        port = 443
      }
      protocols {
        type = "Http"
        port = 80
      }
      terminate_tls    = false
      source_addresses = ["*"]
      web_categories = [
        "ChildAbuseImages",
        "Gambling",
        "HateAndIntolerance",
        "IllegalDrug",
        "IllegalSoftware",
        "Nudity",
        "Violence",
        "Weapons"
      ]
    }
  }

  network_rule_collection {
    name     = "AllowAllToAll"
    action   = "Allow"
    priority = 300

    rule {
      name                  = "Allow-VPN-To-Internet"
      protocols             = ["Any"]
      source_addresses      = ["10.111.1.0/24"]
      destination_addresses = ["0.0.0.0/0"]
      destination_ports     = ["*"]
    }
    rule {
      name                  = "Allow-VPN-To-Internal"
      protocols             = ["Any"]
      source_addresses      = ["10.111.1.0/24"]
      destination_addresses = ["10.101.100.0/22"]
      destination_ports     = ["*"]
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall
resource "azurerm_firewall" "this" {
  name                = "afw-example"
  resource_group_name = azurerm_resource_group.this.name
  location            = "northeurope"
  sku_name            = "AZFW_Hub"
  sku_tier            = "Standard"
  virtual_hub {
    virtual_hub_id  = azurerm_virtual_hub.this.id
    public_ip_count = 1
  }
  firewall_policy_id = azurerm_firewall_policy.this.id
  # can't specify public ip: https://github.com/hashicorp/terraform-provider-azurerm/issues/22543

}
