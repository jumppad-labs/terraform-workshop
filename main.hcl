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
    // working_directory = editor.vscode.working_directory
  }
}

resource "local_exec" "docs" {
  depends_on = ["resource.docs.docs"]
  command = [
    "./scripts/startup_check.sh"
  ]

  timeout = "120s"
}

/*
resource "editor" "vscode" {
  tab "docs" {
    type   = "browser"
    uri    = variable.docs_url
    active = true
  }

  tab "terminal" {
    type     = "terminal"
    location = "editor"
  }

  extensions = [
    "hashicorp.hcl",
    "hashicorp.terraform"
  ]

  working_directory = "/files"

  auth {
    password = ""
  }

  volume {
    from        = resource.container.vault
    source      = "/etc/vault"
    destination = "/files/vault"
  }

  volume {
    from        = resource.container.consul
    source      = "/etc/consul"
    destination = "/files/consul"
  }

  port {
    local  = 8000
    remote = 8000
    host   = 8000
  }
}
*/

/*
resource "terraform" "test" {
  path = "./workspace"

  variables = {
    first = "first"
    second = 2
    third = {
      x = 3
      y = 3
    }
  }

  volume {
    source = "${home()}/.terraform.d"
    destination = "/root/.terraform.d,ro"
  }
}
*/

/*
resource "vm" "test" {
  arch = "x86_64" // default -> host arch

  image = "/path/to/vm-image.qcow2" // .iso .img

  resources {
    cpus = 2
    memory = 4096 // mb
  }

  disk "name" {
    type = "ext4"
    size = 100 // mb
  }

  volume {
    source = "/path/on/host"
    destination = "/path/in/vm"
  }

  network {
    id = resource.network.main.id
    ip_address = "10.0.10.5"
  }

  port {
    local  = 8000
    remote = 8000
    host   = 8000
  }

  cloud_config = <<-EOF
  runcmd: |-
    apt update
    apt install -y curl
  EOF
}
*/

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
