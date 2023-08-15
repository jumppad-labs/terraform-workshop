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
  subnet = "10.10.0.0/16"
}

resource "copy" "workspace" {
  source      = "./workspace"
  destination = data("terraform")
  permissions = "0755"
}

// rename to documentation
resource "docs" "docs" {
  network {
    id = resource.network.main.id
  }

  image {
    name = "ghcr.io/jumppad-labs/docs:v0.3.0"
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

module "course" {
  source = "${dir()}/course"

  variables = {
    terraform_target  = "resource.container.vscode"
    working_directory = "/terraform_basics"

    // future idea
    // working_directory = resource.container.vscode.volume.workdir.destination
  }
}

resource "local_exec" "docs" {
  depends_on = ["resource.docs.docs"]
  command = [
    "./scripts/startup_check.sh"
  ]

  timeout = "120s"
}

resource "container" "vscode" {
  depends_on = ["resource.local_exec.docs"]

  network {
    id = resource.network.main.id
  }

  image {
    name = "ghcr.io/jumppad-labs/terraform-workshop:v0.3.2"
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
    timeout = "60s"
    http {
      address       = "http://vscode.container.jumppad.dev:8000/"
      success_codes = [200, 302, 403]
    }
  }
}
