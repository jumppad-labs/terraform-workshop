resource "chapter" "providers" {
  title = "Providers"

  page "install_provider" {
    title = "Find and install providers"
    content = file("${dir()}/docs/providers/install_provider.mdx")
    tasks = {
      install_provider = resource.task.install_provider.id
    }
  }

  page "provider_configuration" {
    title = "Configuration"
    content = file("${dir()}/docs/providers/provider_configuration.mdx")
    tasks = {
      provider_configuration = resource.task.provider_configuration.id
    }
  }
}

resource "task" "install_provider" {
  prerequisites = resource.chapter.workflow.tasks

  condition "provider_added" {
    description = "The vault provider is added to the code"
    check = file("${dir()}/checks/providers/install_provider/provider_added")
    failure_message = "The \"hashicorp/vault\" provider was not added to required_providers"
    target = variable.terraform_target
  }

  condition "provider_installed" {
    description = "The vault provider is installed"
    check = file("${dir()}/checks/providers/install_provider/provider_installed")
    failure_message = "the vault provider was not correctly initialized"
    target = variable.terraform_target
  }
}

resource "task" "provider_configuration" {
  prerequisites = [
    resource.task.install_provider.id
  ]

  condition "configuration_added" {
    description = "The provider configuration is added"
    check = file("${dir()}/checks/providers/provider_configuration/configuration_added")
    failure_message = "The provider configuration does not specify the Vault address"
    target = variable.terraform_target
  }
}