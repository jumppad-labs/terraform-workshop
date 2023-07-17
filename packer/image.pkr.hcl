packer {
  required_plugins {
    googlecompute = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}

source "googlecompute" "instruqt_terraform" {
  project_id   = "jumppad"
  source_image = "debian-10-buster-v20230711"
  ssh_username = "packer"
  zone         = "europe-west1-b"
}

build {
  sources = ["sources.googlecompute.instruqt_terraform"]

  provisioner "shell" {
    script       = "script.sh"
    pause_before = "10s"
    timeout      = "600s"
  }
}
