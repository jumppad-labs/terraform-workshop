resource "chapter" "installation" {
  title = "Install terraform"

  page "manual_installation" {
    title = "Manual installation"
    content = file("${dir()}/docs/installation/manual_installation.mdx")
    tasks = {
      manual_installation = resource.task.manual_installation.id
    }
  }

  page "verify_installation" {
    title = "Verify installation"
    content = file("${dir()}/docs/installation/verify_installation.mdx")
    tasks = {
      verify_installation = resource.task.verify_installation.id
    }
  }

  page "terraform_version" {
    title = "Terraform version"
    content = file("${dir()}/docs/installation/terraform_version.mdx")
    tasks = {
      terraform_version = resource.task.terraform_version.id
    }
  }
}

resource "task" "manual_installation" {

  condition "binary_exists" {
    description = "Terraform installed on path"
    check = file("${dir()}/checks/installation/manual_installation/binary_exists")
    solve = file("${dir()}/checks/installation/manual_installation/solve")
    failure_message = "terraform binary not found on the PATH"
    target = variable.terraform_target
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
    check = template_file("${dir()}/checks/installation/manual_installation/version_latest", { name = "terraform"})
    failure_message = "terraform binary is not the latest version"
    target = variable.terraform_target
  }
}

resource "task" "verify_installation" {
  prerequisites = [
    resource.task.manual_installation.id
  ]


  condition "help_command" {
    description = "Use the terraform -help command"
    solve = file("${dir()}/checks/installation/verify_installation/solve")
    check = file("${dir()}/checks/installation/verify_installation/help_command")
    failure_message = "'terraform -help' command was not used to explore the possibilities of the CLI"
    target = variable.terraform_target
  }
}

resource "task" "terraform_version" {
  prerequisites = [
    resource.task.verify_installation.id
  ]


  condition  "version_command" {
    description = "Use the terraform version command"
    check = file("${dir()}/checks/installation/terraform_version/version_command")
    solve = file("${dir()}/checks/installation/terraform_version/solve")
    failure_message = "'terraform version' command was not used to validate the installed version"
    target = variable.terraform_target
  }
}