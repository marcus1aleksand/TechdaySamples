resource "azurerm_public_ip" "greenpublicip" {
  depends_on          = [azurerm_kubernetes_cluster.aks_green]
  name                = "akspublicipgreen"
  resource_group_name = format("MC_%s_%s-aks-green_%s", lower(var.resource_group_name),lower(var.env), lower(var.location))
  sku                 = "Standard"
  location            = var.location
  allocation_method   = "Static"
  domain_name_label   = format("%s-green", lower(var.env))

  tags = {
    environment = var.env
  }
}

resource "azurerm_kubernetes_cluster" "aks_green" {
  depends_on             = [azurerm_resource_group.bluegreen]
  name                = format("%s-aks-green", lower(var.env))
  location            = var.location
  resource_group_name = var.resource_group_name
  kubernetes_version  = var.green_version
  dns_prefix          = format("%s-aks-green", lower(var.env))

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

resource "helm_release" "nginx_green" {
  depends_on = [azurerm_kubernetes_cluster.aks_green,azurerm_public_ip.greenpublicip]
  name       = "ingress-nginx"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "4.2.3"
  provider = helm.green


  set {
        name  = "controller.service.loadBalancerIP"
        value = azurerm_public_ip.greenpublicip.ip_address
      }

  values = [file("../helm/ingress/values.yaml")]
}


resource "helm_release" "certmanagergreen" {
  depends_on = [helm_release.nginx_green]
  name       = "certmanager"
  namespace  = "certmanager"
  create_namespace = true
  chart      = "../helm/cert-manager"
  provider = helm.green

  values = [file("../helm/cert-manager/values.yaml")]

}

resource "helm_release" "clusterissuergreen" {
  depends_on = [helm_release.certmanagergreen]
  name       = "clusterissuer"
  namespace  = "certmanager"
  chart      = "../helm/clusterissuer"
  provider = helm.green

  values = [file("../helm/clusterissuer/values.yaml")]

}

resource "helm_release" "app_green" {
  depends_on = [helm_release.clusterissuergreen]
  name       = "mysite"
  namespace  = "mysite"
  create_namespace = true
  chart      = "../helm/mysite"
  provider = helm.green

  set {
        name  = "mysite.ingress.url"
        value = format("%s-bluegreen.trafficmanager.net", lower(var.env))
      }

  values = [file("../helm/mysite/values.yaml")]

}

output "client_certificate_green" {
  value     = azurerm_kubernetes_cluster.aks_green.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config_green" {
  value = azurerm_kubernetes_cluster.aks_green.kube_config_raw

  sensitive = true
}

output "dns_service_ip_green" {
  value = azurerm_kubernetes_cluster.aks_green.dns_prefix

  sensitive = false
}

output "application_url" {
  value = format("https://%s-bluegreen.trafficmanager.net", lower(var.env))

  sensitive = false
}