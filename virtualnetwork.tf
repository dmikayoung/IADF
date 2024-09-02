resource "azurerm_virtual_network" "vnet" {
  name                = "virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subnetaz" {
  name                 = "subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  
}

resource "azurerm_lb" "lb_azure" {
  name                = "load-balancer"
  sku                 = "Standard"
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                 = "private-frontend"
    private_ip_address_allocation = "Static"
    private_ip_address    = "10.0.1.4" 
    subnet_id            = azurerm_subnet.subnetaz.id
  }
}

resource "azurerm_private_link_service" "link_privado" {
  name                = "link-privado"
  location            = var.location
  resource_group_name = var.resource_group_name

  load_balancer_frontend_ip_configuration_ids = [azurerm_lb.lb_azure.frontend_ip_configuration[0].id]

  nat_ip_configuration {
    name                       = "primary"
    private_ip_address         = "10.5.1.17"
    private_ip_address_version = "IPv4"
    subnet_id                  = azurerm_subnet.subnetaz.id
    primary                    = true
  }

  nat_ip_configuration {
    name                       = "secondary"
    private_ip_address         = "10.0.1.18"
    private_ip_address_version = "IPv4"
    subnet_id                  = azurerm_subnet.subnetaz.id
    primary                    = false
  }
}
# Endpoint privado para restrição de rede 
resource "azurerm_private_endpoint" "endpoint_privado" {
  name                = "endpoint-privado"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.subnetaz.id

  private_service_connection {
    name                           = "servico-conexao-privado"
    private_connection_resource_id = azurerm_private_link_service.link_privado.id
    is_manual_connection           = false
  }
}

# Configuração de Runtime de integração no ADF para permitir execução de pipelines dentro de uma rede privada
resource "azurerm_data_factory" "adf_privado" {
  name                = "adf-privado"
  location            = var.location
  resource_group_name = var.resource_group_name
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_factory_integration_runtime_self_hosted" "irsh_private" {
  name                = "irsh-private"
  data_factory_id = azurerm_data_factory.adf_privado.id
}