variable "vm_count" {
    description = "The number of virtual machines"
    type        = number
    default     = 2
}

variable "base_rke2_macaddr" {
    description = "The base MAC address of the virtual machines"
    type        = string
    default     = "BC:24:11:23:32:00"
}

variable "container_vm_name" {
    description = "The name of the container virtual machine"
    type        = string
    default     = "container-docker-ubuntu-24-04-home-amd64"
}

variable "tuner_vm_name" {
    description = "The name of the mirakurun virtual machine"
    type        = string
    default     = "mirakurun-docker-ubuntu-24-04-home-amd64"
}
