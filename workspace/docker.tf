resource "docker_image" "alpine" {
  name = "alpine:3.16"
}

resource "docker_container" "alpine" {
  name    = "terraform-basics"
  image   = docker_image.alpine.image_id
  command = ["tail", "-f", "/dev/null"]
}
