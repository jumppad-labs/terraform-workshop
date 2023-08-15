resource "chapter" "state" {
  title = "State"

  tasks = {
    viewing_state = resource.task.viewing_state
    list_state = resource.task.list_state
    show_state = resource.task.show_state
  }

  page "viewing_state" {
    content = file("docs/state/viewing_state.mdx")
  }

  page "list_state" {
    content = file("docs/state/list_state.mdx")
  }

  page "show_state" {
    content = file("docs/state/show_state.mdx")
  }
}

resource "task" "viewing_state" {
  prerequisites = resource.chapter.providers.tasks != null ? values(resource.chapter.providers.tasks).*.id : []

  config {
    user = "root"
    target = variable.terraform_target
  }

  condition "show_command" {
    description = "The Terraform state is viewed"

    setup {
      script = file("checks/state/viewing_state/setup")
    }

    check {
      script = file("checks/state/viewing_state/show_command")
      failure_message = "The terraform show command was not used to view the state"
    }

    solve {
      script = file("checks/state/viewing_state/solve")
    }
  }

  condition "json_flag" {
    description = "The state is in a machine-readable format"

    check {
      script = file("checks/state/viewing_state/json_flag")
      failure_message = "The terraform state was not viewed in a machine-readable format such as JSON"
    }
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

    check {
      script = file("checks/state/list_state/list_command")
      failure_message = "The terraform state list command was not used"
    }

    solve {
      script = file("checks/state/list_state/solve")
    }
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

    check {
      script = file("checks/state/show_state/show_command")
      failure_message = "The terraform state show command was not used to view the state for docker_container.vault"
    }

    solve {
      script = file("checks/state/show_state/solve")
    }
  }
}
