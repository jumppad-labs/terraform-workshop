resource "chapter" "workflow" {
  title = "Terraform workflow"

  tasks = {
    terraform_init = resource.task.terraform_init
    terraform_plan = resource.task.terraform_plan
    terraform_apply = resource.task.terraform_apply
    update_resources = resource.task.update_resources
    terraform_destroy = resource.task.terraform_destroy
  }

  page "terraform_init" {
    content = file("docs/workflow/terraform_init.mdx")
  }

  page "terraform_plan" {
    content = file("docs/workflow/terraform_plan.mdx")
  }

  page "terraform_apply" {
    content = file("docs/workflow/terraform_apply.mdx")
  }

  page "update_resources" {
    content = file("docs/workflow/update_resources.mdx")
  }

  page "terraform_destroy" {
    content = file("docs/workflow/terraform_destroy.mdx")
  }
}

resource "task" "terraform_init" {
  prerequisites = resource.chapter.installation.tasks != null ? values(resource.chapter.installation.tasks).*.id : []

  config {
    user = "root"
    target = variable.terraform_target
  }

  condition "init_command" {
    description = "The terraform_basics working directory is initialized"

    check {
      script = file("checks/workflow/terraform_init/init_command")
      failure_message = "'terraform init' command was not used to initialize the working directory"
    }

    solve {
      script = file("checks/workflow/terraform_init/solve")
      timeout = 120
    }
  }

  condition "dependency_lock_file" {
    description = "The terraform lock file has been created"

    check {
      script = file("checks/workflow/terraform_init/dependency_lock_file")
      failure_message = "'.terraform.lock.hcl' file does not exist"
    }
  }

  condition "docker_provider" {
    description = "The Docker provider is initialized"

    check {
      script = file("checks/workflow/terraform_init/docker_provider")
      failure_message = "the docker provider was not correctly initialized"
    }
  }
}

resource "task" "terraform_plan" {
  prerequisites = [
    resource.task.terraform_init.id
  ]

  config {
    user = "root"
    target = variable.terraform_target
  }

  condition "plan_command" {
    description = "Use the terraform plan command"

    check {
      script = file("checks/workflow/terraform_plan/plan_command")
      failure_message = "'terraform plan' command was not used to preview changes"
    }

    solve {
      script = file("checks/workflow/terraform_plan/solve")
    }
  }
}

resource task "terraform_apply" {
  prerequisites = [
    resource.task.terraform_plan.id
  ]

  config {
    user = "root"
    target = variable.terraform_target
  }

  condition "apply_command" {
    description = "Use the terraform apply command"
    
    check {
      script = file("checks/workflow/terraform_apply/apply_command")
      failure_message = "'terraform apply' command was not used to apply changes"
    }

    solve {
      script = file("checks/workflow/terraform_apply/solve")
      timeout = 300
    }
  }

  condition "state_image" {
    description = "The Terraform state contains the Docker image"

    check {
      script = file("checks/workflow/terraform_apply/state_image")
      failure_message = "docker_image.vault not found in terraform state"
    }
  }

   condition "state_container" {
    description = "The Terraform state contains the Docker container"

    check {
      script = file("checks/workflow/terraform_apply/state_container")
      failure_message = "docker_container.vault not found in terraform state"
    }
  }

  condition "docker_image" {
    description = "The Docker image is created"

    check {
      script = file("checks/workflow/terraform_apply/docker_image")
      failure_message = "the docker \"vault\" image with tag \"1.12.6\" was not pulled"
    }
  }

  condition "docker_container" {
    description = "The Docker container is running"

    check {
      script = file("checks/workflow/terraform_apply/docker_container")
      failure_message = "the docker container named \"terraform-basics-vault\" is not running"
    }
  }
}

resource "task" "update_resources" {
  prerequisites = [
    resource.task.terraform_apply.id
  ]

  config {
    user = "root"
    target = variable.terraform_target
  }

  condition "update_code" {
    description = "Change the version of the vault image"

    check {
      script = file("checks/workflow/update_resources/update_code")
      failure_message = "The version of the vault image has not been updated to 1.12.7"
    }

    solve {
      script = file("checks/workflow/update_resources/solve")
      timeout = 300
    }
  }

  condition "state_changed" {
    description = "The Terraform state is updated"

    check {
      script = file("checks/workflow/update_resources/state_changed")
      failure_message = "The Terraform state does not contain the updated resources"
    }
  }

  condition "docker_image" {
    description = "The Docker image is updated"

    check {
      script = file("checks/workflow/update_resources/docker_image")
      failure_message = "the docker 'vault' image with tag '1.12.7' was not pulled"
    }
  }

  condition "docker_container" {
    description = "The Docker container is running"

    check {
      script = file("checks/workflow/update_resources/docker_container")
      failure_message = "the docker container named 'terraform-basics-vault' is not running"
    }
  }
}

resource "task" "terraform_destroy" {
  prerequisites = [
    resource.task.update_resources.id
  ]

  config {
    user = "root"
    target = variable.terraform_target
  }

  condition "destroy_command" {
    description = "Use the terraform destroy command"

    check {
      script = file("checks/workflow/terraform_destroy/destroy_command")
      failure_message = "'terraform destroy' command was not used to clean up the environment"
    }

    solve {
      script = file("checks/workflow/terraform_destroy/solve")
    }
  }

  condition "state_empty" {
    description = "The Terraform state is empty"

    check {
      script = file("checks/workflow/terraform_destroy/state_empty")
      failure_message = "the terraform state is not empty"
    }
  }

  condition "docker_container" {
    description = "The Docker container is removed"

    check {
      script = file("checks/workflow/terraform_destroy/docker_container")
      failure_message = "the docker container named 'terraform-basics-vault' is still running"
    }
  }

  condition "docker_image" {
    description = "The Docker container is removed"

    check {
      script = file("checks/workflow/terraform_destroy/docker_image")
      failure_message = "the docker 'vault' image with tag '1.12.7' was not removed"
    }
  }
}