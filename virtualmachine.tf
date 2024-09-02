resource "azurerm_managed_disk" "maquina_virtual" {
  name                 = "maquina-virtual"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "127"
}

resource "azurerm_network_interface" "ani" {
  name                = "network-interface"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnetaz.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm_windows" {
  name                = "windows-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_F2"
  admin_username      = "Minsait1234"
  admin_password      = var.admin_password

network_interface_ids = [
    azurerm_network_interface.ani.id,
  ]
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "security-group"
  location            = var.location
  resource_group_name = var.resource_group_name

}

resource "azurerm_network_security_rule" "security_rule" {
  name                        = "regra-de-seguranca"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_subnet_network_security_group_association" "sg_association" {
  subnet_id                 = azurerm_subnet.subnetaz.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}