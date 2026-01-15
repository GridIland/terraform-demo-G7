terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

# La magie opère ici avec "count"
resource "docker_container" "app_server" {
  count = var.server_count # Crée autant de ressources que le nombre défini
  
  image = docker_image.nginx.image_id
  name  = "server-web-${count.index + 1}" # Ex: server-web-1, server-web-2

  ports {
    internal = 80
    # Chaque serveur aura un port unique : 8080, 8081, 8082...
    external = var.base_port + count.index 
  }
}
