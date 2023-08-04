resource "chapter" "workflow" {
  title = "Terraform workflow"

  page "terraform_init" {
    title = "Terraform init"
    content = file("${dir()}/docs/workflow/terraform_init.mdx")
    tasks = {
      terraform_init = resource.task.terraform_init.id
    }
  }

  page "terraform_plan" {
    title = "Terraform plan"
    content = file("${dir()}/docs/workflow/terraform_plan.mdx")
    tasks = {
      terraform_plan = resource.task.terraform_plan.id
    }
  }

  page "terraform_apply" {
    title = "Terraform apply"
    content = file("${dir()}/docs/workflow/terraform_apply.mdx")
    tasks = {
      terraform_apply = resource.task.terraform_apply.id
    }
  }

  page "update_resources" {
    title = "Update resources"
    content = file("${dir()}/docs/workflow/update_resources.mdx")
    tasks = {
      update_resources = resource.task.update_resources.id
    }
  }

  page "terraform_destroy" {
    title = "Terraform destroy"
    content = file("${dir()}/docs/workflow/terraform_destroy.mdx")
    tasks = {
      terraform_destroy = resource.task.terraform_destroy.id
    }
  }
}

resource "task" "terraform_init" {
  prerequisites = resource.chapter.installation.tasks

  condition "init_command" {
    description = "The terraform_basics working directory is initialized"
    check = file("${dir()}/checks/workflow/terraform_init/init_command")
    solve = file("${dir()}/checks/workflow/terraform_init/solve")
    failure_message = "'terraform init' command was not used to initialize the working directory"
    target = variable.terraform_target
  }

  condition "dependency_lock_file" {
    description = "The terraform lock file has been created"
    check = file("${dir()}/checks/workflow/terraform_init/dependency_lock_file")
    failure_message = "'.terraform.lock.hcl' file does not exist"
    target = variable.terraform_target
  }

  condition "docker_provider" {
    description = "The Docker provider is initialized"
    check = file("${dir()}/checks/workflow/terraform_init/docker_provider")
    failure_message = "the docker provider was not correctly initialized"
    target = variable.terraform_target
  }
}

resource "task" "terraform_plan" {
  prerequisites = [
    resource.task.terraform_init.id
  ]

  condition "plan_command" {
    description = "Use the terraform plan command"
    check = file("${dir()}/checks/workflow/terraform_plan/plan_command")
    solve = file("${dir()}/checks/workflow/terraform_plan/solve")
    failure_message = "'terraform plan' command was not used to preview changes"
    target = variable.terraform_target
  }
}

resource task "terraform_apply" {
  prerequisites = [
    resource.task.terraform_plan.id
  ]

  condition "apply_command" {
    description = "Use the terraform apply command"
    check = file("${dir()}/checks/workflow/terraform_apply/apply_command")
    solve = file("${dir()}/checks/workflow/terraform_apply/solve")
    failure_message = "'terraform apply' command was not used to apply changes"
    target = variable.terraform_target
  }

  condition "state_image" {
    description = "The Terraform state contains the Docker image"
    check = file("${dir()}/checks/workflow/terraform_apply/state_image")
    failure_message = "docker_image.vault not found in terraform state"
    target = variable.terraform_target
  }

   condition "state_container" {
    description = "The Terraform state contains the Docker container"
    check = file("${dir()}/checks/workflow/terraform_apply/state_container")
    failure_message = "docker_container.vault not found in terraform state"
    target = variable.terraform_target
  }

  condition "docker_image" {
    description = "The Docker image is created"
    check = file("${dir()}/checks/workflow/terraform_apply/docker_image")
    failure_message = "the docker \"vault\" image with tag \"1.12.6\" was not pulled"
    target = variable.terraform_target
  }

  condition "docker_container" {
    description = "The Docker container is running"
    check = file("${dir()}/checks/workflow/terraform_apply/docker_container")
    failure_message = "the docker container named \"terraform-basics-vault\" is not running"
    target = variable.terraform_target
  }
}

resource "task" "update_resources" {
  prerequisites = [
    resource.task.terraform_apply.id
  ]

  condition "update_code" {
    description = "Change the version of the vault image"
    check = file("${dir()}/checks/workflow/update_resources/update_code")
    solve = file("${dir()}/checks/workflow/update_resources/solve")
    failure_message = "The version of the vault image has not been updated to 1.13.2"
    target = variable.terraform_target
  }

  condition "state_changed" {
    description = "The Terraform state is updated"
    check = file("${dir()}/checks/workflow/update_resources/state_changed")
    failure_message = "The Terraform state does not contain the updated resources"
    target = variable.terraform_target
  }

  condition "docker_image" {
    description = "The Docker image is updated"
    check = file("${dir()}/checks/workflow/update_resources/docker_image")
    failure_message = "the docker 'vault' image with tag '1.13.2' was not pulled"
    target = variable.terraform_target
  }

  condition "docker_container" {
    description = "The Docker container is running"
    check = file("${dir()}/checks/workflow/update_resources/docker_container")
    failure_message = "the docker container named 'terraform-basics-vault' is not running"
    target = variable.terraform_target
  }
}

resource "task" "terraform_destroy" {
  prerequisites = [
    resource.task.update_resources.id
  ]

  condition "destroy_command" {
    description = "Use the terraform destroy command"
    check = file("${dir()}/checks/workflow/terraform_destroy/destroy_command")
    solve = file("${dir()}/checks/workflow/terraform_destroy/solve")
    failure_message = "'terraform destroy' command was not used to clean up the environment"
    target = variable.terraform_target
  }

  condition "state_empty" {
    description = "The Terraform state is empty"
    check = file("${dir()}/checks/workflow/terraform_destroy/state_empty")
    failure_message = "the terraform state is not empty"
    target = variable.terraform_target
  }

  condition "docker_container" {
    description = "The Docker container is removed"
    check = file("${dir()}/checks/workflow/terraform_destroy/docker_container")
    failure_message = "the docker container named 'terraform-basics-vault' is still running"
    target = variable.terraform_target
  }

  condition "docker_image" {
    description = "The Docker container is removed"
    check = file("${dir()}/checks/workflow/terraform_destroy/docker_image")
    failure_message = "the docker 'vault' image with tag '1.13.2' was not removed"
    target = variable.terraform_target
  }
}