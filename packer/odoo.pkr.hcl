packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}

source "googlecompute" "odoo-base" {
  project_id              = var.project_id
  source_image_family     = "debian-12"
  source_image_project_id = ["debian-cloud"]
  
  zone                    = var.zone
  machine_type           = "e2-standard-4"
  disk_size              = 10
  disk_type              = "pd-ssd"
  
  image_name             = "odoo-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  image_family           = "odoo-production"
  image_description      = "Odoo 17 - Built with Packer"
  
  ssh_username           = "packer"
  
  tags = ["packer", "odoo"]
  
  use_internal_ip = false
  omit_external_ip = false
}

build {
  name = "odoo-image"
  
  sources = ["source.googlecompute.odoo-base"]

  provisioner "file" {
    source      = "scripts/"
    destination = "/tmp/"
  }

  provisioner "shell" {
    script = "scripts/install-system.sh"
    execute_command = "sudo bash {{.Path}}"
  }

  provisioner "shell" {
    script = "scripts/install-odoo.sh"
    execute_command = "sudo bash {{.Path}}"
  }

  provisioner "shell" {
    script = "scripts/install-esocial.sh"
    execute_command = "sudo bash {{.Path}}"
  }


  provisioner "shell" {
    script = "scripts/optimize-image.sh"
    execute_command = "sudo bash {{.Path}}"
  }

  provisioner "shell" {
    inline = [
      "echo '✅ OK'"
    ]
  }
}
