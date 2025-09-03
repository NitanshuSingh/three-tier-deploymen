rg = {
  elearn-rg = {
    rg_location = "centralindia"
  }
}

vnet = {
  elearn-vnet = {
    address_space = ["10.0.0.0/16"]
    rg_name       = "elearn-rg"
    location      = "centralindia"
  }
}

subnet = {
  frontendSubnet = {
    address_prefixes = ["10.0.0.0/24"]
    rg_name          = "elearn-rg"
    vnet_name        = "elearn-vnet"
  }
  backendSubnet = {
    address_prefixes = ["10.0.1.0/24"]
    rg_name          = "elearn-rg"
    vnet_name        = "elearn-vnet"
  }
}

nic = {
  fontend-vm-nic = {
    rg_name     = "elearn-rg"
    location    = "centralindia"
    subnet_name = "frontendSubnet"
    pip_name    = "frontend-pip"
  }
  backend-vm-nic = {
    rg_name     = "elearn-rg"
    location    = "centralindia"
    subnet_name = "backendSubnet"
    pip_name    = "backend-pip"
  }
}

vm = {
  frontend-vm = {
    admin_username = "elearnadmin"
    admin_password = "Admin@123"
    rg_name        = "elearn-rg"
    location       = "centralindia"
    nic_name       = "fontend-vm-nic"
  }
  backend-vm = {
    admin_username = "elearnadmin"
    admin_password = "Admin@123"
    rg_name        = "elearn-rg"
    location       = "centralindia"
    nic_name       = "backend-vm-nic"
  }
}

pip = {
  frontend-pip = {
    rg_name  = "elearn-rg"
    location = "centralindia"
  }
  backend-pip = {
    rg_name  = "elearn-rg"
    location = "centralindia"
  }
}

nsg = {
  frontend-nsg = {
    location                   = "centralindia"
    rg_name                    = "elearn-rg"
    rule_name                  = "ssh-port-open"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  backend-nsg = {
    location                   = "centralindia"
    rg_name                    = "elearn-rg"
    rule_name                  = "ssh-port-open"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

associations = {
  association1 = {
    nic_name = "fontend-vm-nic"
    nsg_name = "frontend-nsg"
  }
  association2 = {
    nic_name = "backend-vm-nic"
    nsg_name = "backend-nsg"
  }
}

