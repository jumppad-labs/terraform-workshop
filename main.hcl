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

variable "docs_url" {
  default = "http://localhost"
}

variable "vscode_token" {
  default = "token"
}

resource "network" "main" {
  subnet = "10.100.0.0/16"
}

resource "copy" "workspace" {
  source      = "./workspace"
  destination = data("terraform")
  permissions = "0755"
}

module "course" {
  source = "${dir()}/course"

  variables = {
    terraform_target  = "resource.container.vscode"
    working_directory = "/terraform_basics"

    // future idea
    // working_directory = resource.container.vscode.volume.workdir.destination
  }
}

resource "docs" "docs" {
  network {
    id = resource.network.main.meta.id
  }

  /* 
  have docs support multiple paths that get combined into docs?
  grabs all the books from the library and generates navigation
  mounts the library to a volume
  */

  // logo {
  //   url = "https://companieslogo.com/img/orig/HCP.D-be08ca6f.png"
  //   width = 32
  //   height = 32
  // }

  content = [
    module.course.output.book
  ]

  assets = "${dir()}/assets"
}

resource "template" "vscode_jumppad" {
  source      = <<-EOF
  {
  "tabs": [
    {
      "name": "Docs",
      "uri": "${variable.docs_url}",
      "type": "browser",
      "active": true
    },
    {
      "name": "Terminal",
      "location": "editor",
      "type": "terminal"
    }
  ]
  }
  EOF
  destination = "${data("vscode")}/workspace.json"
}

resource "container" "vscode" {
  network {
    id = resource.network.main.meta.id
  }

  image {
    name = "ghcr.io/jumppad-labs/terraform-workshop:v0.4.0"
  }

  volume {
    source      = "${dir()}/scripts"
    destination = "/var/lib/jumppad/"
  }

  volume {
    source      = data("terraform")
    destination = "/terraform_basics"
  }

  volume {
    source      = resource.template.vscode_jumppad.destination
    destination = "/terraform_basics/.vscode/workspace.json"
  }

  volume {
    source      = "/var/run/docker.sock"
    destination = "/var/run/docker.sock"
  }

  environment = {
    EXTENSIONS       = "hashicorp.hcl,hashicorp.terraform"
    CONNECTION_TOKEN = variable.vscode_token
    DEFAULT_FOLDER   = "/terraform_basics"
  }

  port {
    local  = 8000
    remote = 8000
    host   = 8000
  }

  health_check {
    timeout = "100s"

    http {
      address       = "http://${resource.docs.docs.fqdn}/docs/terraform_basics/introduction/what_is_terraform"
      success_codes = [200]
    }

    http {
      address       = "http://localhost:8000/"
      success_codes = [200, 302, 403]
    }
  }
}