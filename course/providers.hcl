resource "chapter" "providers" {
  title = "Providers"

  tasks = {
    install_provider = resource.task.install_provider
    provider_configuration = resource.task.provider_configuration
  }

  pages = {
    install_provider = "docs/providers/install_provider.mdx"
    provider_configuration = "docs/providers/provider_configuration.mdx"
  }
}

resource "task" "install_provider" {
  // prerequisites = [
  //   resource.task.terraform_init.id,
  //   resource.task.terraform_plan.id,
  //   resource.task.terraform_apply.id,
  //   resource.task.update_resources.id,
  //   resource.task.terraform_destroy.id
  // ]
  prerequisites = resource.chapter.workflow.tasks != null ? values(resource.chapter.workflow.tasks).*.id : []

  config {
    user = "root"
    target = variable.terraform_target
  }

  condition "provider_added" {
    description = "The vault provider is added to the code"
    check = file("${dir()}/checks/providers/install_provider/provider_added")
    solve = file("${dir()}/checks/providers/install_provider/solve")
    failure_message = "The \"hashicorp/vault\" provider was not added to required_providers"
  }

  condition "provider_installed" {
    description = "The vault provider is installed"
    check = file("${dir()}/checks/providers/install_provider/provider_installed")
    failure_message = "the vault provider was not correctly initialized"
  }
}

resource "task" "provider_configuration" {
  prerequisites = [
    resource.task.install_provider.id
  ]

  config {
    user = "root"
    target = variable.terraform_target
  }

  condition "configuration_added" {
    description = "The provider configuration is added"
    check = file("${dir()}/checks/providers/provider_configuration/configuration_added")
    solve = file("${dir()}/checks/providers/provider_configuration/solve")
    failure_message = "The provider configuration does not specify the Vault address"
  }
}