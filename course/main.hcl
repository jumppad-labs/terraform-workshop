// blueprint {
//   version = "v0.1.0"
// }

resource "book" "terraform_basics" {
  title = "Understanding Terraform basics"

  chapters = [
    resource.chapter.introduction.id,
    resource.chapter.installation.id,
    resource.chapter.workflow.id,
    resource.chapter.providers.id,
    resource.chapter.state.id,
    resource.chapter.summary.id
  ]
}

resource "chapter" "introduction" {
  title = "Introduction"
  page "what_is_terraform" {
    title = "What is Terraform?"
    content = file("${dir()}/docs/introduction/what_is_terraform.mdx")
  }

  page "what_will_you_learn" {
    title = "What will you learn?"
    content = file("${dir()}/docs/introduction/what_will_you_learn.mdx")
  }

  page "workshow_environment" {
    title = "Workshop environment"
    content = file("${dir()}/docs/introduction/workshop_environment.mdx")
  }
}

resource "chapter" "summary" {
  page "summary" {
    title = "Summary"
    content = file("${dir()}/docs/summary.mdx")
  }
}

output "book" {
  value = resource.book.terraform_basics.id
}