resource "azurerm_resource_group" "bluegreen" {
  name     = var.resource_group_name
  location = var.location
}