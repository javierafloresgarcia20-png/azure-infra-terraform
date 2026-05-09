terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "mtc-lab-infra"
  location = var.location

  tags = {
    Environment = "Lab"
    Project     = "MTC-HomeLab"
  }
}

# Networking
resource "azurerm_virtual_network" "vnet" {
  name                = "mtc-vnet"
  address_space       = ["10.123.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = { Environment = "Lab" }
}

resource "azurerm_subnet" "subnet" {
  name                 = "mtc-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.123.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "mtc-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = { Environment = "Lab" }
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "Allow-SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# VM Resources
resource "azurerm_public_ip" "vm_ip" {
  name                = "mtc-vm-public-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = { Environment = "Lab" }
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "mtc-vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_ip.id
  }
  tags = { Environment = "Lab" }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "mtc-lab-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_D2s_v3"
  admin_username        = "azureuser"

  network_interface_ids = [azurerm_network_interface.vm_nic.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = filebase64("customdata.tpl")

  tags = { Environment = "Lab" }
}

# Outputs
data "azurerm_public_ip" "vm_ip_data" {
  name                = azurerm_public_ip.vm_ip.name
  resource_group_name = azurerm_resource_group.rg.name
}

output "vm_public_ip" {
  description = "Public IP address of the Linux VM"
  value       = data.azurerm_public_ip.vm_ip_data.ip_address
}

output "vm_ssh_command" {
  description = "SSH command to connect"
  value       = "ssh azureuser@${data.azurerm_public_ip.vm_ip_data.ip_address}"
}