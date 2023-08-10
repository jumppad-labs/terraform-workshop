// blueprint {
//   version = "v0.1.0"
// }

resource "book" "terraform_basics" {
  title = "Understanding Terraform basics"

  chapters = [
    resource.chapter.introduction,
    resource.chapter.installation,
    resource.chapter.workflow,
    resource.chapter.providers,
    resource.chapter.state,
    resource.chapter.summary
  ]
}

resource "chapter" "introduction" {
  title = "Introduction"

  tasks = {}

  pages = {
    what_is_terraform = "docs/introduction/what_is_terraform.mdx"
    what_will_you_learn = "docs/introduction/what_will_you_learn.mdx"
    workshow_environment = "docs/introduction/workshop_environment.mdx"
  }
}

resource "chapter" "summary" {
  tasks = {}

  pages = {
    summary = "docs/summary.mdx"
  }
}

output "book" {
  value = resource.book.terraform_basics
}