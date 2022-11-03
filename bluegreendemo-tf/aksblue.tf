resource "azurerm_public_ip" "bluepublicip" {
  depends_on          = [azurerm_kubernetes_cluster.aks_blue]
  name                = "akspublicipblue"
  resource_group_name = format("MC_%s_%s-aks-blue_%s", lower(var.resource_group_name),lower(var.env), lower(var.location))
  sku                 = "Standard"
  location            = var.location
  allocation_method   = "Static"
  domain_name_label   = format("%s-blue", lower(var.env))

  tags = {
    environment = var.env
  }
}

resource "azurerm_kubernetes_cluster" "aks_blue" {
  depends_on          = [azurerm_resource_group.bluegreen]
  name                = format("%s-aks-blue", lower(var.env))
  location            = var.location
  resource_group_name = var.resource_group_name
  kubernetes_version  = var.blue_version
  dns_prefix          = format("%s-aks-blue", lower(var.env))

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.env
  }
}

resource "helm_release" "nginx_blue" {
  depends_on = [azurerm_kubernetes_cluster.aks_blue]
  name       = "ingress-nginx"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "4.2.3"
  provider= helm.blue


  set {
        name  = "controller.service.loadBalancerIP"
        value = azurerm_public_ip.bluepublicip.ip_address
      }

  values = [file("../helm/ingress/values.yaml")]
  
}

resource "helm_release" "certmanagerblue" {
  depends_on = [helm_release.nginx_blue]
  name       = "certmanager"
  namespace  = "certmanager"
  create_namespace = true
  chart      = "../helm/cert-manager"
  provider = helm.blue

  values = [file("../helm/cert-manager/values.yaml")]

}

resource "helm_release" "clusterissuerblue" {
  depends_on = [helm_release.certmanagerblue]
  name       = "clusterissuer"
  namespace  = "certmanager"
  chart      = "../helm/clusterissuer"
  provider = helm.blue

  values = [file("../helm/clusterissuer/values.yaml")]

}

resource "helm_release" "app_blue" {
  depends_on = [helm_release.clusterissuerblue]
  name       = "mysite"
  namespace  = "mysite"
  create_namespace = true
  chart      = "../helm/mysite"
  provider = helm.blue

  set {
        name  = "mysite.ingress.url"
        value = format("%s-bluegreen.trafficmanager.net", lower(var.env))
      }
  
  values = [file("../helm/mysite/values.yaml")]

}

output "client_certificate_blue" {
  value     = azurerm_kubernetes_cluster.aks_blue.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config_blue" {
  value = azurerm_kubernetes_cluster.aks_blue.kube_config_raw

  sensitive = true
}

output "dns_service_ip_blue" {
  value = azurerm_kubernetes_cluster.aks_blue.dns_prefix

  sensitive = false
}
