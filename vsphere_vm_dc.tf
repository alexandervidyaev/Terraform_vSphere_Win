terraform {
  required_providers {
    vsphere = {
      source  = "terraform.local/local/vsphere"
      version = "2.1.1"
      # Other parameters...
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = "vg-vcenter-01.vlab.local"
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "Datacenter"
}
data "vsphere_datastore" "datastore" {
  name          = "vsanDatastore"
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_compute_cluster" "cluster" {
  name          = "vSAN Cluster"
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  count            = length(var.vm_names)
  name             = var.vm_names[count.index]
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.vm_folder
  num_cpus         = var.vm_cpu
  memory           = var.vm_mem
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  firmware         = var.vm_firmware
  scsi_type        = "lsilogic-sas"

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      windows_options {
        computer_name         = var.vm_names[count.index]
        join_domain           = var.dc
        domain_admin_user     = var.dc_administrator
        domain_admin_password = var.dc_password
      }
      network_interface {
        ipv4_address = var.vm_network_ips[count.index]
        ipv4_netmask = var.vm_network_mask
      }

      dns_server_list = var.vm_network_dns
      ipv4_gateway    = var.vm_network_gateway

    }
  }

  lifecycle {
    ignore_changes = all
  }
}

