resource "proxmox_vm_qemu" "rke2_server" {
  # options
  vmid        = 40000
  protection  = true
  name        = master-rke2-server-ubuntu-24-04-home-amd64
  agent       = 1 # qemu-guest-agent
  onboot      = false
  automatic_reboot = true

  # hardware
  ## boot
  bios        = "seabios"
  boot        = "order=scsi0"
  target_node = "pve-nucbox-3"
  clone       = "ubuntu-24-04-home-amd64"
  full_clone  = false

  # cpu
  vcpus = 0 # this is set automatically by Proxmox to sockets * cores. https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/vm_qemu
  cores = 2
  sockets = 1
  cpu_type = "x86-64-v2-AES"


  ## memory
  memory = 5120
  balloon = 0

  # network
  network {
    id = 0
    model  = "virtio"
    bridge = "vmbr0"
    firewall = false
    macaddr = "BC:24:11:97:96:BB"
  }
  # disk
  disks {
    scsi {
        scsi0 {
            disk {
                backup = true
                emulatessd = true
                size = "20G"
                storage = "int-ssd"
            }
        }
    }
  }
}

locals {
  vm_names = [for i in range(var.vm_count) : format("worker-%02d-rke2-agent-ubuntu-24-04-home-amd64", i + 1)]
  macaddrs = [for i in range(var.vm_count) : format("%s%02X", substr(var.base_rke2_macaddr, 0, length(var.base_rke2_macaddr) - 2), i + 1)]
vmids = [for i in range(var.vm_count) : 50001 + i]
}

resource "proxmox_vm_qemu" "rke2_worker" {
  for_each = { for idx, name in local.vm_names : name => { macaddr = local.macaddrs[idx], vmid = local.vmids[idx] } }
  # options
  vmid        = each.value.vmid
  protection  = true
  name        = each.key
  agent       = 1 # qemu-guest-agent
  onboot     = false
  automatic_reboot = true

  # hardware
  ## boot
  bios        = "seabios"
  boot        = "order=scsi0"
  target_node = "pve-nucbox-3"
  clone       = "template-rke2-agent-ubuntu-24-04-home-amd64"
  full_clone  = false

  ## cpu
  vcpus = 0 # this is set automatically by Proxmox to sockets * cores. https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/vm_qemu
  cores = 1
  sockets = 1
  cpu_type = "x86-64-v2-AES"

  ## memory
  memory = 1024
  balloon = 0

  # network
  network {
    id = 0
    model  = "virtio"
    bridge = "vmbr0"
    firewall = false
    macaddr = each.value.macaddr
  }

  # disk
  disks {
    scsi {
        scsi0 {
            disk {
                backup = true
                emulatessd = true
                size = "20G"
                storage = "int-ssd"
            }
        }
    }
  }

}

resource "proxmox_vm_qemu" "mm_kiosk" {
  # options
  vmid        = 10000
  protection  = true
  name        = var.mm_kiosk_vm_name
  agent       = 1 # qemu-guest-agent
  onboot      = false
  automatic_reboot = true

  # hardware
  ## boot
  bios        = "seabios"
  boot        = "order=scsi0"
  target_node = "pve-nucbox-3"
  clone       = "rocky-9-home-amd64"
  full_clone  = false

  ## cpu
  vcpus = 0 # this is set automatically by Proxmox to sockets * cores. https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/vm_qemu
  cores = 1
  sockets = 1
  cpu_type = "x86-64-v2-AES"

  ## memory
  memory = 640
  balloon = 0

  # network
  network {
    id = 0
    model  = "virtio"
    bridge = "vmbr0"
    firewall = false
    macaddr = "52:54:00:c1:3a:38"
  }

  # disk
  disks {
    scsi {
        scsi0 {
            disk {
                backup = true
                emulatessd = true
                size = "25G"
                storage = "int-ssd"
            }
        }
    }
  }
  # PCI device
  pcis {
    pci0 {
      mapping {
        mapping_id = "int_gpu_nucbox_3"
        pcie = false
        primary_gpu = false
        rombar = false
        device_id = "0x0301"
        vendor_id = "0x02f3"
        sub_device_id = ""
        sub_vendor_id = ""
      }
    }
  }
}

resource "proxmox_vm_qemu" "container" {
  # options
  vmid        = 20000
  protection  = true
  name        = var.container_vm_name
  agent       = 1 # qemu-guest-agent
  onboot     = true
  automatic_reboot = true

  # hardware
  ## boot
  bios        = "seabios"
  boot        = "order=scsi0"
  target_node = "pve-nucbox-3"
  clone       = "docker-ubuntu-24-04-home-amd64"
  full_clone  = false

  ## cpu
  vcpus = 0 # this is set automatically by Proxmox to sockets * cores. https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/vm_qemu
  cores = 1
  sockets = 1
  cpu_type = "x86-64-v2-AES"

  ## memory
  memory = 2048
  balloon = 0

  # network
  network {
    id = 0
    model  = "virtio"
    bridge = "vmbr0"
    firewall = false
    macaddr = "bc:24:11:db:b0:f6"
  }

  # disk
  disks {
    scsi {
        scsi0 {
            disk {
                backup = true
                emulatessd = true
                size = "25G"
                storage = "int-ssd"
            }
        }
    }
  }

}

resource "proxmox_vm_qemu" "tuner" {
  # options
  vmid        = 30000
  protection  = true
  name        = var.tuner_vm_name
  agent       = 1 # qemu-guest-agent
  automatic_reboot = true
  onboot      = true

  # hardware
  ## boot
  scsihw      = "virtio-scsi-single"
  bios        = "seabios"
  boot        = "order=scsi0"
  target_node = "pve-prodesk"
  clone       = "docker-ubuntu-24-04-home-amd64"
  full_clone  = false

  ## cpu
  vcpus = 0 # this is set automatically by Proxmox to sockets * cores. https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/vm_qemu
  cores = 1
  sockets = 1
  cpu_type = "host"

  ## memory
  memory = 9216
  balloon = 0

  # network
  network {
    id = 0
    model  = "virtio"
    bridge = "vmbr0"
    firewall = false
    macaddr = "52:54:00:23:98:fc"
  }

  # disk
  disks {
    scsi {
        scsi0 {
            disk {
                backup = true
                emulatessd = false
                size = "20G"
                storage = "local"
                iothread = true
                replicate = true
            }
        }
    }
  }
  # PCI device
  pcis {
    pci0 {
      mapping {
        mapping_id = "tuner_earthsoft"
        pcie = false
        primary_gpu = false
        rombar = false
        device_id = "0xee8d"
        vendor_id = "0x0368"
        sub_device_id = ""
        sub_vendor_id = ""
      }
    }
  }

}
