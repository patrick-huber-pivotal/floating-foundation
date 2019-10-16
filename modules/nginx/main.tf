resource "azurerm_network_interface" "nginx" {
    count                 = var.instance_count

    name                = "${var.location}-ngingx-${count.index}"
    location            = var.location
    resource_group_name = var.resource_group_name

    ip_configuration {
        name                          = "${var.location}-nginx"
        subnet_id                     = var.subnet_id        
        private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_virtual_machine" "nginx" {
    count                 = var.instance_count

    name                  = "${var.location}-nginx-${count.index}"
    location              = var.location
    resource_group_name   = var.resource_group_name
    network_interface_ids = [azurerm_network_interface.nginx.id]
    vm_size               = var.vm_size

    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher = "nginxinc"
        offer     = "nginx-plus-v1"
        sku       = "nginx-plus-ub1804"
        version   = "latest"
    }

    storage_os_disk {
        name              = "${var.location}-nginx"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    os_profile {
        computer_name  = "${var.location}-nginx"
        admin_username = var.os_user
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
