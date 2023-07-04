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
  page "introduction" {
    title = "Introduction"
    content = file("${dir()}/docs/index.mdx")
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