resource "azurerm_network_security_group" "jumphost" {
  name                = "${var.location}-jumphost"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "jumphost_ssh" {
  name                        = "${var.location}-jumphost-ssh"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.jumphost.name

  priority  = 100
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_address_prefix      = "*"
  source_port_range          = "*"
  destination_port_range     = "22"
  destination_address_prefix = "*"
}

resource "azurerm_public_ip" "jumphost" {
  name                         = "${var.location}-jumphost"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  allocation_method            = "Static"
}

resource "azurerm_network_interface" "jumphost" {
    name                = "${var.location}-jumphost"
    location            = var.location
    resource_group_name = var.resource_group_name

    network_security_group_id = azurerm_network_security_group.jumphost.id

    ip_configuration {
        name                          = "${var.location}-jumphost"
        subnet_id                     = var.subnet_id
        public_ip_address_id          = azurerm_public_ip.jumphost.id
        private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_virtual_machine" "jumphost" {
    name                  = "${var.location}-jumphost"
    location              = var.location
    resource_group_name   = var.resource_group_name
    network_interface_ids = [azurerm_network_interface.jumphost.id]
    vm_size               = var.vm_size

    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    storage_os_disk {
        name              = "${var.location}-jumphost"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    os_profile {
        computer_name  = "${var.location}-jumphost"
        admin_username = "azure-user"
        admin_password = "none"        
    }

    os_profile_linux_config {
        disable_password_authentication = true

        ssh_keys {
            path        = "/home/${var.os_user}/.ssh/authorized_keys}"
            key_data    = var.public_key_data
        }
    }
}
