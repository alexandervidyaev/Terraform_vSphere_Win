template_name    = "WS2019_terraform_ready"
vm_folder        = "Hyper-V S2D stand"
dc               = "corp.local"
dc_administrator = "Administrator"
dc_password      = "XXXX"
vsphere_user     = "vidyaevaa@vlab.local"
vsphere_password = "XXXX"
vsphere_network  = "common|C-OVS-AP|C-OVS-TRAF-EPG"
vm_firmware      = "efi"
vm_cpu           = "4"
vm_mem           = "8192"

vm_names = {
  "0" = "test-1"
  "1" = "test-2"
  "2" = "test-3"
}

vm_network_ips = {
  "0" = "10.7.160.55"
  "1" = "10.7.160.56"
  "2" = "10.7.160.57"
}

vm_network_mask    = "27"
vm_network_gateway = "10.7.160.33"
vm_network_dns     = ["10.6.24.114", "8.8.8.8"]
