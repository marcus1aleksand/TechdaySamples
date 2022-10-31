terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
provider "azurerm" {
  features {}
}

provider "helm" {
  alias = "green"
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks_green.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks_green.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks_green.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks_green.kube_config.0.cluster_ca_certificate)
  }
}

provider "helm" {
  alias = "blue"
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks_blue.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks_blue.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks_blue.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks_blue.kube_config.0.cluster_ca_certificate)
  }
}
