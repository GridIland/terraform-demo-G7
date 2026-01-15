terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

provider "docker" {}

# 1. L'image Docker (inchangée)
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

# 2. On crée le site web DANS Terraform (C'est la nouveauté)
resource "local_file" "website" {
  filename = "${path.cwd}/index.html"
  content  = <<EOF
    <html>
      <body style="background-color: #3498db; color: white; text-align: center; padding-top: 100px; font-family: sans-serif;">
        <h1>INFRASTRUCTURE V1</h1>
        <p>Déployé avec Terraform</p>
      </body>
    </html>
  EOF
}

# 3. Le conteneur avec le fichier monté
resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "mon_site_web"
  
  ports {
    internal = 80
    external = 8080
  }

  # On injecte le fichier créé par Terraform dans le conteneur
  volumes {
    host_path      = abspath(local_file.website.filename)
    container_path = "/usr/share/nginx/html/index.html"
  }
}
