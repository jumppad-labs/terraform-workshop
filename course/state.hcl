resource "chapter" "state" {
  title = "State"

  page "viewing_state" {
    title = "Viewing state"
    content = file("${dir()}/docs/state/viewing_state.mdx")
    tasks = {
      viewing_state = resource.task.viewing_state.id
    }
  }

  page "list_state" {
    title = "List state"
    content = file("${dir()}/docs/state/list_state.mdx")
    tasks = {
      list_state = resource.task.list_state.id
    }
  }

  page "show_state" {
    title = "Show state"
    content = file("${dir()}/docs/state/show_state.mdx")
    tasks = {
      show_state = resource.task.show_state.id
    }
  }
}

resource "task" "viewing_state" {
  prerequisites = resource.chapter.providers.tasks

  condition "show_command" {
    description = "The Terraform state is viewed"
    check = file("${dir()}/checks/state/viewing_state/show_command")
    solve = file("${dir()}/checks/state/viewing_state/solve")
    failure_message = "The terraform show command was not used to view the state"
    target = variable.terraform_target
  }

  condition "json_flag" {
    description = "The state is in a machine-readable format"
    check = file("${dir()}/checks/state/viewing_state/json_flag")
    failure_message = "The terraform state was not viewed in a machine-readable format such as JSON"
    target = variable.terraform_target
  }
}

resource "task" "list_state" {
  prerequisites = [
    resource.task.viewing_state.id
  ]

  condition "list_command" {
    description = "The state for all resources is listed"
    check = file("${dir()}/checks/state/list_state/list_command")
    solve = file("${dir()}/checks/state/list_state/solve")
    failure_message = "The terraform state list command was not used"
    target = variable.terraform_target
  }
}

resource "task" "show_state" {
  prerequisites = [
    resource.task.list_state.id
  ]

  condition "show_command" {
    description = "The state of the Vault Docker container was shown"
    check = file("${dir()}/checks/state/show_state/show_command")
    solve = file("${dir()}/checks/state/show_state/solve")
    failure_message = "The terraform state show command was not used to view the state for docker_container.vault"
    target = variable.terraform_target
  }
}
