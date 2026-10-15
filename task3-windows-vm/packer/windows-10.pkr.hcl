
variable "iso_path" {
  type    = string
  default = "C:/Users/tibin/Downloads/Windows10.iso"
}

variable "vm_name" {
  type    = string
  default = "Win10-Malware-Lab"
}

variable "winrm_password" {
  type      = string
  sensitive = true
}

source "virtualbox-iso" "windows10" {
  vm_name       = var.vm_name
  guest_os_type = "Windows10_64"

  iso_url      = var.iso_path
  iso_checksum = "sha256:6b56b5b8f2d2c9f63243f7672d580dc2e87661730f59784f812b6987488856f8"

  cpus      = 1
  memory    = 4096
  disk_size = 30720

  guest_additions_mode = "disable"

  # Attach the VM only to the dedicated host-only lab network.
  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--nic1", "hostonly"],
    ["modifyvm", "{{.Name}}", "--hostonlyadapter1", "VirtualBox Host-Only Ethernet Adapter #2"],
    ["modifyvm", "{{.Name}}", "--clipboard", "disabled"],
    ["modifyvm", "{{.Name}}", "--draganddrop", "disabled"]
  ]

  # Boot the Windows ISO and use the unattended answer file.
  boot_wait    = "10s"
  boot_command = ["<spacebar>"]

  floppy_content = {
    "Autounattend.xml" = templatefile("../scripts/Autounattend.xml", {
      winrm_password = var.winrm_password
    })
  }

  # Connect to the static host-only IP configured in Autounattend.xml.
  communicator   = "winrm"
  winrm_host     = "192.168.57.10"
  winrm_port     = 5985
  winrm_username = "labadmin"
  winrm_password = var.winrm_password
  winrm_timeout  = "90m"

  shutdown_command = "shutdown /s /t 10 /f"
  shutdown_timeout = "30m"
}

build {
  name    = "windows10-malware-lab"
  sources = ["source.virtualbox-iso.windows10"]

  provisioner "powershell" {
    scripts = ["../scripts/Hardening.ps1"]
  }
}
