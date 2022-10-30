terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.15.00"
    }
  }
  backend "azurerm" {
    resource_group_name = var.bkstrgrg
    storage_account_name = var.bkstrg
    container_name = var.bkcontainer
    key = var.bkstrgkey
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "vnet_rg" {
  name     = var.resourcegroup_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.vnet_rg.location
  resource_group_name = azurerm_resource_group.vnet_rg.name
  tags                = var.tags
}

resource "azurerm_subnet" "subnet" {
  for_each = var.subnets
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  name                 = each.value["name"]
  address_prefixes     = each.value["address_prefixes"]
}

resource "azurerm_public_ip" "bastion_pubip" {
  name                = "${var.bastionhost_name}PubIP"
  location            = azurerm_resource_group.vnet_rg.location
  resource_group_name = azurerm_resource_group.vnet_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "bastion" {
  name                = var.bastionhost_name
  location            = azurerm_resource_group.vnet_rg.location
  resource_group_name = azurerm_resource_group.vnet_rg.name
  tags                = var.tags

  ip_configuration {
    name                 = "bastion_config"
    subnet_id            = azurerm_subnet.subnet["bastion_subnet"].id
    public_ip_address_id = azurerm_public_ip.bastion_pubip.id
  }
}


# resource "azurerm_kubernetes_cluster" "prodact" {
#   name                = "prodact-aks1"
#   location            = var.location
#   resource_group_name = var.resourcegroup_name
#   dns_prefix          = "prodactaks1"

#   default_node_pool {
#     name       = "default"
#     node_count = 1
#     vm_size    = "Standard_B2s"
#   }

#   identity {
#     type = "SystemAssigned"
#   }

#   tags = {
#     Environment = "Production"
#   }
# }

# output "client_certificate" {
#   value     = azurerm_kubernetes_cluster.prodact.kube_config.0.client_certificate
#   sensitive = true
# }

# output "kube_config" {
#   value = azurerm_kubernetes_cluster.prodact.kube_config_raw

#   sensitive = true
# }




# resource "azurerm_public_ip" "prodact" {
#   name                = "PublicIPForLB"
#   location            = var.location
#   resource_group_name = var.resourcegroup_name
#   allocation_method   = "Static"
# }

# resource "azurerm_lb" "prodact" {
#   name                = "TestLoadBalancer"
#   location            = var.location
#   resource_group_name = var.resourcegroup_name

#   frontend_ip_configuration {
#     name                 = "PublicIPAddress"
#     public_ip_address_id = azurerm_public_ip.prodact.id
#   }
# }






# # Create a resource group
# resource "azurerm_resource_group" "product" {
#   name     = "product-resources"
#   location = "East US"
# }

# # Create a virtual network within the resource group
# resource "azurerm_virtual_network" "product" {
#   name                = "product-network"
#   resource_group_name = azurerm_resource_group.product.name
#   location            = azurerm_resource_group.product.location
#   address_space       = ["10.0.0.0/16"]
# }

# resource "azurerm_kubernetes_cluster" "product" {
#   name                = "product-aks1"
#   location            = azurerm_resource_group.product.location
#   resource_group_name = azurerm_resource_group.product.name
#   dns_prefix          = "productaks1"

#   default_node_pool {
#     name       = "default"
#     node_count = 1
#     vm_size    = "Standard_B2s"
#   }

#   identity {
#     type = "SystemAssigned"
#   }

#   tags = {
#     Environment = "Production"
#   }
# }

# output "client_certificate" {
#   value = azurerm_kubernetes_cluster.product.kube_config.0.client_certificate
# }

# output "kube_config" {
#   value = azurerm_kubernetes_cluster.product.kube_config_raw

#   sensitive = true
# }
