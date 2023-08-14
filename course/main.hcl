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

  page "what_is_terraform" {
    content = file("docs/introduction/what_is_terraform.mdx")
  }

  page "what_will_you_learn" {
    content = file("docs/introduction/what_will_you_learn.mdx")
  }

  page "workshow_environment" {
    content = file("docs/introduction/workshop_environment.mdx")
  }
}

resource "chapter" "summary" {
  tasks = {}

  page "summary" {
    content = file("docs/summary.mdx")
  }
}

output "book" {
  value = resource.book.terraform_basics
}