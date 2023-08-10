resource "chapter" "state" {
  title = "State"

  tasks = {
    viewing_state = resource.task.viewing_state
    list_state = resource.task.list_state
    show_state = resource.task.show_state
  }

  pages = {
    viewing_state = "docs/providers/viewing_state.mdx"
    list_state = "docs/providers/list_state.mdx"
    show_state = "docs/providers/show_state.mdx"
  }
}

resource "task" "viewing_state" {
  prerequisites = resource.chapter.state.tasks != null ? values(resource.chapter.state.tasks).*.id : []

  config {
    user = "root"
    target = variable.terraform_target
  }

  condition "show_command" {
    description = "The Terraform state is viewed"
    check = file("${dir()}/checks/state/viewing_state/show_command")
    solve = file("${dir()}/checks/state/viewing_state/solve")
    failure_message = "The terraform show command was not used to view the state"
  }

  condition "json_flag" {
    description = "The state is in a machine-readable format"
    check = file("${dir()}/checks/state/viewing_state/json_flag")
    failure_message = "The terraform state was not viewed in a machine-readable format such as JSON"
  }
}

resource "task" "list_state" {
  prerequisites = [
    resource.task.viewing_state.id
  ]

  config {
    user = "root"
    target = variable.terraform_target
  }

  condition "list_command" {
    description = "The state for all resources is listed"
    check = file("${dir()}/checks/state/list_state/list_command")
    solve = file("${dir()}/checks/state/list_state/solve")
    failure_message = "The terraform state list command was not used"
  }
}

resource "task" "show_state" {
  prerequisites = [
    resource.task.list_state.id
  ]

  config {
    user = "root"
    target = variable.terraform_target
  }

  condition "show_command" {
    description = "The state of the Vault Docker container was shown"
    check = file("${dir()}/checks/state/show_state/show_command")
    solve = file("${dir()}/checks/state/show_state/solve")
    failure_message = "The terraform state show command was not used to view the state for docker_container.vault"
  }
}
