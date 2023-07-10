/*
backend {
  disabled = !var.backend_remote
  // sends it to remote backend
}

backend {
  disabled = !var.backend_cloud
  // uses jumppad cloud
  // fields overlap mostly with remote 
  // but doesnt need an address
}

backend {
  disabled = !var.backend_local
  // sends it to local backend (gets deleted on purge)
}
*/

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

// rename to documentation
resource "docs" "docs" {
  network {
    id = resource.network.main.id
  }

  image {
    name = "ghcr.io/jumppad-labs/docs:v0.0.2"
  }

  /* 
  have docs support multiple paths that get combined into docs?
  grabs all the books from the library and generates navigation
  mounts the library to a volume
  */

  content = [
    module.course.output.book
  ]
}

module "course" {
  source = "${dir()}/course"

  variables = {
    terraform_target = resource.container.vscode.id
    working_directory = "/terraform_basics"

    // future idea
    // working_directory = resource.container.vscode.volume.workdir.destination
  }
}

resource "container" "vscode" {
  network {
    id = resource.network.main.id
  }

  image {
    name = "ghcr.io/jumppad-labs/terraform-workshop:v0.1.0"
  }

  volume {
    source = "${dir()}/scripts"
    destination = "/var/lib/jumppad/"
  }

  volume {
    source = data("terraform")
    destination = "/terraform_basics"
  }

  // volume {
  //   source = "${dir()}/settings"
  //   destination = "/root/.local/share/code-server/Machine"
  // }

  volume {
    source = "${dir()}/settings"
    destination = "/terraform_basics/.vscode"
  }

  volume {
    source = "/var/run/docker.sock"
    destination = "/var/run/docker.sock"
  }

  environment = {
    EXTENSIONS = "hashicorp.hcl,hashicorp.terraform"
    CONNECTION_TOKEN = variable.vscode_token
    DEFAULT_FOLDER = "/terraform_basics"
  }

  port {
    local = 8000
    remote = 8000
    host = 8000
  }

  health_check {
    timeout = "60s"
    http {
      address = "http://vscode.container.jumppad.dev:8000/"
      success_codes = [200,302,403]
    }
  }
}