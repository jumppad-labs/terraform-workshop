variable "vscode_token" {
  default = "token"
}

resource "network" "main" {
  subnet = "10.10.0.0/16"
}

resource "copy" "workspace" {  
  source = "./workspace"  
  destination = data("terraform")  
  permissions = "0755"
}

resource "docs" "docs" {
  network {
    id = resource.network.main.id
  }

  image {
    name = "ghcr.io/jumppad-labs/docs:v0.0.1"
  }

  path = "${dir()}/docs"
  navigation_file = "${dir()}/config/navigation.jsx"
}

resource "container" "vscode" {
  network {
    id = resource.network.main.id
  }

  image {
    name = "ghcr.io/jumppad-labs/vscode:base-v0.0.1"
  }

  volume {
    source = "${data("vscode")}/settings.json"
    destination = "/root/.vscode-server/data/Machine/settings.json"
  }

  volume {
    source = data("terraform")
    destination = "/terraform_basics"
  }

  environment = {
    EXTENSIONS = "file-icons.file-icons,sdras.night-owl,hashicorp.hcl,hashicorp.terraform"
    CONNECTION_TOKEN = variable.vscode_token
    DEFAULT_FOLDER = "/terraform_basics"
  }

  port {
    local = 8000
    remote = 8000
    host = 8000
  }
}