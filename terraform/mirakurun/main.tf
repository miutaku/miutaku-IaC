resource "proxmox_vm_qemu" "vm" {
  # options
  protection  = true
  name        = var.vm_name
  agent       = 1 # qemu-guest-agent
  automatic_reboot = true

  # hardware
  ## boot
  bios        = "seabios"
  boot        = "order=scsi0"
  target_node = "pve-nucbox-3"
  clone       = "mirakurun-docker-ubuntu-24-04-home-amd64"
  full_clone  = false

  ## cpu
  vcpus = 0 # this is set automatically by Proxmox to sockets * cores. https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/vm_qemu
  cores = 1
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
    macaddr = "52:54:00:23:98:fc"
  }

  # disk
  disks {
    scsi {
        scsi0 {
            disk {
                backup = true
                emulatessd = true
                size = "20G"
                storage = "local"
            }
        }
    }
  }
  # PCI device
  pcis {
    pci0 {
        raw {
            raw_id = "0000:01:00.0"
        }
    }
  }

}
