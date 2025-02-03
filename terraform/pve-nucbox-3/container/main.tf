resource "proxmox_vm_qemu" "vm" {
  # options
  protection  = true
  name        = var.vm_name
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
  memory = 1024
  balloon = 0

  # network
  network {
    id = 0
    model  = "virtio"
    bridge = "vmbr0"
    firewall = false
    macaddr = "BC:24:11:DB:B0:F6"
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
