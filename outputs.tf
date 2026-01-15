output "server_names" {
  value = docker_container.app_server[*].name
  description = "Les noms des conteneurs créés"
}

output "access_urls" {
  # Une boucle 'for' pour générer la liste des URLs cliquables
  value = [for i in range(var.server_count) : "http://localhost:${var.base_port + i}"]
  description = "Les URLs pour accéder aux sites"
}
