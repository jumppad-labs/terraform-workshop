resource "docker_image" "vault" {
  name = "vault:1.12.6"
}

resource "docker_container" "vault" {
  name  = "terraform-basics-vault"
  image = docker_image.vault.image_id

  ports {
    internal = 8200
    external = 8200
  }
}
