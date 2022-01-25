# ----------------------------------------------------------------------------
# Name:         photon4.pkr.hcl
# Description:  Build definition for Photon 4
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         29/10/2021
# ----------------------------------------------------------------------------

# -------------------------------------------------------------------------- #
#                           Packer Configuration                             #
# -------------------------------------------------------------------------- #
packer {
    required_version = ">= 1.7.7"
    required_plugins {
        vsphere = {
            version = ">= v1.0.2"
            source  = "github.com/hashicorp/vsphere"
        }
    }
}

# -------------------------------------------------------------------------- #
#                              Local Variables                               #
# -------------------------------------------------------------------------- #
locals { 
    build_version   = formatdate("YY.MM", timestamp())
    build_date      = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
}

# -------------------------------------------------------------------------- #
#                       Template Source Definitions                          #
# -------------------------------------------------------------------------- #
source "vsphere-iso" "photon4" {
    # vCenter
    vcenter_server              = var.vcenter_server
    username                    = var.vcenter_username
    password                    = var.vcenter_password
    insecure_connection         = var.vcenter_insecure
    datacenter                  = var.vcenter_datacenter
    cluster                     = var.vcenter_cluster
    folder                      = var.vcenter_folder
    datastore                   = var.vcenter_datastore

    # Content Library and Template Settings
    convert_to_template         = var.vcenter_convert_template
    create_snapshot             = var.vcenter_snapshot
    snapshot_name               = var.vcenter_snapshot_name
    dynamic "content_library_destination" {
        for_each = var.vcenter_content_library_name != null ? [1] : []
            content {
                library         = var.vcenter_content_library_name
                ovf             = var.vcenter_content_library_ovf
                destroy         = var.vcenter_content_library_destroy
                skip_import     = var.vcenter_content_library_skip
            }
    }

    # Virtual Machine
    guest_os_type               = var.vm_os_type
    vm_name                     = "photon4-${ var.build_branch }-${ local.build_version }"
    notes                       = "VER: ${ local.build_version }\nDATE: ${ local.build_date }\nSRC: ${ var.build_repo } (${ var.build_branch })\nOS: ${ var.vm_os_vendor } ${ var.vm_os_version } ${ var.vm_os_type }\nISO: ${ var.os_iso_file }"
    firmware                    = var.vm_firmware
    CPUs                        = var.vm_cpu_sockets
    cpu_cores                   = var.vm_cpu_cores
    CPU_hot_plug                = var.vm_cpu_hotadd
    RAM                         = var.vm_mem_size
    RAM_hot_plug                = var.vm_mem_hotadd
    cdrom_type                  = var.vm_cdrom_type
    remove_cdrom                = var.vm_cdrom_remove
    disk_controller_type        = var.vm_disk_controller
    storage {
        disk_size               = var.vm_disk_size
        disk_thin_provisioned   = var.vm_disk_thin
    }
    network_adapters {
        network                 = var.vcenter_network
        network_card            = var.vm_nic_type
    }

    # Removeable Media
    iso_paths                   = ["[${ var.os_iso_datastore }] ${ var.os_iso_path }/${ var.os_iso_file }"]

    # Boot and Provisioner
    http_directory              = var.http_directory
    http_port_min               = var.http_port_min
    http_port_max               = var.http_port_max
    boot_order                  = var.vm_boot_order
    boot_wait                   = var.vm_boot_wait
    boot_command                = [ "<esc><wait>c",
                                    "linux /isolinux/vmlinuz root=/dev/ram0 loglevel=3 insecure_installation=1 ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${ var.http_file } photon.media=cdrom",
                                    "<enter>", "initrd /isolinux/initrd.img",
                                    "<enter>",
                                    "boot",
                                    "<enter>" ]
    ip_wait_timeout             = var.vm_ip_timeout
    communicator                = "ssh"
    ssh_username                = var.build_username
    ssh_password                = var.build_password
    shutdown_command            = "sudo shutdown -P now"
    shutdown_timeout            = var.vm_shutdown_timeout
}

# -------------------------------------------------------------------------- #
#                             Build Management                               #
# -------------------------------------------------------------------------- #
build {
    # Build sources
    sources                     = [ "source.vsphere-iso.photon4" ]
    
    # Shell Provisioner to execute scripts 
    provisioner "shell" {
        execute_command         = "echo '${var.build_password}' | {{.Vars}} sudo -E -S sh -eu '{{.Path}}'"
        scripts                 = var.script_files
        valid_exit_codes        = [ 0,245,1535 ]
    }

    post-processor "manifest" {
        output                  = "manifest.txt"
        strip_path              = true
        custom_data             = { vcenter_fqdn    = "${ var.vcenter_server }"
                                    vcenter_folder  = "${ var.vcenter_folder }"
                                    iso_file        = "${ var.os_iso_file }"
                                    build_repo      = "${ var.build_repo }"
                                    build_branch    = "${ var.build_branch }"
        }
    }
}