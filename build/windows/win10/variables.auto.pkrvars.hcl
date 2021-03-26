# ----------------------------------------------------------------------------
# Name:         variables.auto.pkrvars.hcl
# Description:  Common vSphere variables for Windows 10 Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         21/02/2021
# ----------------------------------------------------------------------------

# ISO Settings
os_iso_file_20h2    = "en-gb_windows_10_business_editions_version_20h2_updated_march_2021_x64_dvd_acc0ed5d.iso"
os_iso_file_2004    = "en-gb_windows_10_business_editions_version_2004_updated_march_2021_x64_dvd_5db032c9.iso"
os_iso_path         = "os/microsoft/desktop/10"

# OS Meta Data
os_family           = "Windows"
os_version          = "10"

# VM Hardware Settings
vm_cpu_sockets      = 2
vm_cpu_cores        = 1
vm_mem_size         = 8192
vm_nic_type         = "vmxnet3"
vm_disk_controller  = ["pvscsi"]
vm_disk_size        = 51200
vm_disk_thin        = true
vm_cdrom_type       = "sata"

# VM OS Settings
vm_os_type          = "windows9_64Guest"
vm_boot_cmd         = ["<spacebar>"]
vm_shutdown_cmd     = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Complete\""