resource "chapter" "installation" {
  title = "Install terraform"

  tasks = {
    manual_installation = resource.task.manual_installation
    verify_installation = resource.task.verify_installation
    terraform_version = resource.task.terraform_version
  }

  pages = {
    manual_installation = "docs/installation/manual_installation.mdx"
    verify_installation = "docs/installation/verify_installation.mdx"
    terraform_version = "docs/installation/terraform_version.mdx"
  }
}

resource "task" "manual_installation" {
  config {
    user = "root"
    target = variable.terraform_target
  }

  condition "binary_exists" {
    description = "Terraform installed on path"
    check = file("${dir()}/checks/installation/manual_installation/binary_exists")
    solve = file("${dir()}/checks/installation/manual_installation/solve")
    failure_message = "terraform binary not found on the PATH"
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
    solve = file("${dir()}/checks/installation/verify_installation/solve")
    check = file("${dir()}/checks/installation/verify_installation/help_command")
    failure_message = "'terraform -help' command was not used to explore the possibilities of the CLI"
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
    check = file("${dir()}/checks/installation/terraform_version/version_command")
    solve = file("${dir()}/checks/installation/terraform_version/solve")
    failure_message = "'terraform version' command was not used to validate the installed version"
  }
}