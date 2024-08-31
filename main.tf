terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.0.1"
    }
  }
}

provider "azurerm" {
features {
  
}
}

resource "azurerm_resource_group" "resource_group1" {
  name     = "rg-vnet"
  location = "Brazil South"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.resource_group1.location
  resource_group_name = azurerm_resource_group.resource_group1.name
}

resource "azurerm_subnet" "service" {
  name                 = "service"
  resource_group_name  = azurerm_resource_group.resource_group1.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  
}
# Criação do endpoint
resource "azurerm_subnet" "endpoint" {
  name                 = "endpoint"
  resource_group_name  = azurerm_resource_group.resource_group1.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

 
}

resource "azurerm_public_ip" "ip_publico" {
  name                = "public-ip"
  sku                 = "Standard"
  location            = azurerm_resource_group.resource_group1.location
  resource_group_name = azurerm_resource_group.resource_group1.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "lb_azure" {
  name                = "lb"
  sku                 = "Standard"
  location            = azurerm_resource_group.resource_group1.location
  resource_group_name = azurerm_resource_group.resource_group1.name

  frontend_ip_configuration {
    name                 = azurerm_public_ip.ip_publico.name
    public_ip_address_id = azurerm_public_ip.ip_publico.id
  }
}

resource "azurerm_private_link_service" "link_privado" {
  name                = "link-privado"
  location            = azurerm_resource_group.resource_group1.location
  resource_group_name = azurerm_resource_group.resource_group1.name

  nat_ip_configuration {
    name      = azurerm_public_ip.ip_publico.name
    primary   = true
    subnet_id = azurerm_subnet.service.id
  }

  load_balancer_frontend_ip_configuration_ids = [
    azurerm_lb.lb_azure.frontend_ip_configuration[0].id,
  ]
}
# Endpoint privado para restrição de rede 
resource "azurerm_private_endpoint" "endpoint_privado" {
  name                = "endpoint-privado"
  location            = azurerm_resource_group.resource_group1.location
  resource_group_name = azurerm_resource_group.resource_group1.name
  subnet_id           = azurerm_subnet.endpoint.id

  private_service_connection {
    name                           = "servico-conexao-privado"
    private_connection_resource_id = azurerm_private_link_service.link_privado.id
    is_manual_connection           = false
  }
}

# Configuração de Runtime de integração no ADF para permitir execução de pipelines dentro de uma rede privada
resource "azurerm_data_factory" "adf_privado" {
  name                = "adf-privado"
  location            = azurerm_resource_group.resource_group1.location
  resource_group_name = azurerm_resource_group.resource_group1.name
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_factory_integration_runtime_self_hosted" "irsh_private" {
  name                = "irsh-private"
  data_factory_id = azurerm_data_factory.adf_privado.id
}
