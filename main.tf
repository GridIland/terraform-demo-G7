terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "app_server" {
  count = var.server_count 
  
  image = docker_image.nginx.image_id
  name  = "server-web-${count.index + 1}"

  ports {
    internal = 80
    external = var.base_port + count.index 
  }
}
