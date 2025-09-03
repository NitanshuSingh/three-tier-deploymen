resource "azurerm_resource_group" "rg" {
  for_each = var.rg
  name     = each.key
  location = each.value.rg_location
}

resource "azurerm_virtual_network" "vnet" {
  depends_on          = [azurerm_resource_group.rg]
  for_each            = var.vnet
  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.rg_name
  address_space       = each.value.address_space
}



resource "azurerm_subnet" "subnet" {
  depends_on           = [azurerm_virtual_network.vnet]
  for_each             = var.subnet
  name                 = each.key
  resource_group_name  = each.value.rg_name
  virtual_network_name = each.value.vnet_name
  address_prefixes     = each.value.address_prefixes
}


resource "azurerm_network_interface" "nic" {
  depends_on          = [azurerm_public_ip.pip, azurerm_subnet.subnet]
  for_each            = var.nic
  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet[each.value.subnet_name].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[each.value.pip_name].id
  }
}


resource "azurerm_linux_virtual_machine" "vm" {
  depends_on          = [azurerm_network_interface.nic]
  for_each            = var.vm
  name                = each.key
  resource_group_name = each.value.rg_name
  location            = each.value.location
  size                = "Standard_F2"
  admin_username      = each.value.admin_username
  admin_password      = each.value.admin_password
  network_interface_ids = [
    azurerm_network_interface.nic[each.value.nic_name].id,
  ]
  disable_password_authentication = false
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
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install nginx -y"
    ]
    connection {
      type     = "ssh"
      user     = "elearnadmin"
      password = "Admin@123"
      host     = self.public_ip_address
    }
  }
}


resource "azurerm_public_ip" "pip" {
  depends_on          = [azurerm_resource_group.rg]
  for_each            = var.pip
  name                = each.key
  resource_group_name = each.value.rg_name
  location            = each.value.location
  allocation_method   = "Static"
}


resource "azurerm_network_security_group" "nsg" {
  depends_on          = [azurerm_resource_group.rg]
  for_each            = var.nsg
  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.rg_name

  security_rule {
    name                       = each.value.rule_name
    priority                   = each.value.priority
    direction                  = each.value.direction
    access                     = each.value.access
    protocol                   = each.value.protocol
    source_port_range          = each.value.source_port_range
    destination_port_range     = each.value.destination_port_range
    source_address_prefix      = each.value.source_address_prefix
    destination_address_prefix = each.value.destination_address_prefix
  }

}


resource "azurerm_network_interface_security_group_association" "association" {
  depends_on                = [azurerm_resource_group.rg, azurerm_network_security_group.nsg, azurerm_network_interface.nic]
  for_each                  = var.associations
  network_interface_id      = azurerm_network_interface.nic[each.value.nic_name].id
  network_security_group_id = azurerm_network_security_group.nsg[each.value.nsg_name].id
}

output "public_ip_addresses" {
  description = "List of public IPs assigned to VMs"
  value = {
    for k, pip in azurerm_public_ip.pip :
    k => pip.ip_address
  }
}