resource "azurerm_traffic_manager_profile" "techday" {
  depends_on             = [azurerm_resource_group.bluegreen]
  name                   = format("%s-tm", lower(var.env))
  resource_group_name    = var.resource_group_name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = format("%s-bluegreen", lower(var.env))
    ttl           = 100
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }

  tags = {
    environment = var.env
  }
}

resource "azurerm_traffic_manager_external_endpoint" "blue" {
  name       = "aks-blue"
  profile_id = azurerm_traffic_manager_profile.techday.id
  weight     = 50
  target     = azurerm_public_ip.bluepublicip.fqdn
  enabled    = true
}

resource "azurerm_traffic_manager_external_endpoint" "green" {
  name       = "aks-green"
  profile_id = azurerm_traffic_manager_profile.techday.id
  weight     = 50
  target     = azurerm_public_ip.greenpublicip.fqdn
  enabled    = true
}
