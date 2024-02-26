variable "jumppad_version" {
  type = string
}

variable "jumppad_images" {
  type    = list(string)
  default = []
}

variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "europe-west1"
}

variable "zone" {
  type    = string
  default = "europe-west1-d"
}

packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}

source "googlecompute" "jumppad" {
  project_id = var.project_id
  region     = var.region
  zone       = var.zone

  image_family = "jumppad"
  image_name   = regex_replace("terraform-workshop-${var.jumppad_version}", "[^a-zA-Z0-9_-]", "-")

  source_image_family = "ubuntu-2204-lts"
  machine_type        = "n1-standard-4"
  disk_size           = 20

  ssh_username = "root"
}

build {
  sources = ["source.googlecompute.jumppad"]

  provisioner "file" {
    source      = "files"
    destination = "/tmp/resources"
  }

  provisioner "shell" {
    script = "files/install.sh"
    environment_vars = [
      "JUMPPAD_VERSION=${trimprefix(var.jumppad_version, "v")}",
      "JUMPPAD_IMAGES=${join(" ", var.jumppad_images)}"
    ]
  }
}