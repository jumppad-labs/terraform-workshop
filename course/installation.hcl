resource "chapter" "installation" {
  title = "Install terraform"

  tasks = {
    manual_installation = resource.task.manual_installation
    verify_installation = resource.task.verify_installation
    terraform_version = resource.task.terraform_version
  }

  page "manual_installation" {
    content = file("docs/installation/manual_installation.mdx")
  }

  page "verify_installation" {
    content = file("docs/installation/verify_installation.mdx")
  }
  
  page "terraform_version" {
    content = file("docs/installation/terraform_version.mdx")
  }
}

resource "task" "manual_installation" {
  prerequisites = []
  
  config {
    user = "root"
    target = variable.terraform_target
  }

  condition "binary_exists" {
    description = "Terraform installed on path"

    check {
      script = file("checks/installation/manual_installation/binary_exists")
      failure_message = "terraform binary not found on the PATH"
    }

    solve {
      script = file("checks/installation/manual_installation/solve")
      timeout = 60
    }
  }

  // condition "version_command" {
  //   description = "Terraform version called"
  //   check = <<-EOF
  //     # Is the 'terraform version' command used?
  //     validate history contains --match-line "terraform version"
  //   EOF
  //   failure_message = "'terraform version' command was not used to validate the installed version"
  //   success_message = ":thumbsup:"
  //   target = variable.terraform_target
  // }

  condition "latest_version" {
    description = "Terraform binary is the latest version"

    check {
      script = template_file("checks/installation/manual_installation/version_latest", { name = "terraform"})
      failure_message = "terraform binary is not the latest version"
    }
  }
}

resource "task" "verify_installation" {
  prerequisites = [
    resource.task.manual_installation.id
  ]

  config {
    user = "root"
    target = variable.terraform_target
  }

  condition "help_command" {
    description = "Use the terraform -help command"

    check {
      script = file("checks/installation/verify_installation/help_command")
      failure_message = "'terraform -help' command was not used to explore the possibilities of the CLI"
    }

    solve {
      script = file("checks/installation/verify_installation/solve")
    }
  }
}

resource "task" "terraform_version" {
  prerequisites = [
    resource.task.verify_installation.id
  ]
  
  config {
    user = "root"
    target = variable.terraform_target
  }

  condition  "version_command" {
    description = "Use the terraform version command"

    check {
      script = file("checks/installation/terraform_version/version_command")
      failure_message = "'terraform version' command was not used to validate the installed version"
    }

    solve {
      script = file("checks/installation/terraform_version/solve")
    }
  }
}