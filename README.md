Voici le contenu complet pour le fichier `README.md` de la seconde démo.

Ce document explique clairement la structure modulaire (3 fichiers) et guide l'utilisateur à travers le scénario de mise à l'échelle (Scaling).

---

# Terraform Scalability Demo: Nginx Fleet

Ce projet est une démonstration technique de Terraform mettant en avant les capacités d'abstraction et de scalabilité.

Il simule le déploiement d'une flotte de serveurs web (Nginx) via Docker, en utilisant des **variables**, des **boucles (count)** et des **sorties dynamiques**.

## Objectifs de la démo

* **Modularité :** Séparation du code en 3 fichiers standards (`main.tf`, `variables.tf`, `outputs.tf`).
* **Scalabilité :** Utilisation du méta-argument `count` pour déployer N ressources simultanément.
* **Logique dynamique :** Calcul automatique des ports d'écoute pour éviter les conflits (8080, 8081, 8082...).
* **Variables :** Modification de l'infrastructure via la ligne de commande sans toucher au code source.

## Prérequis

* [Docker](https://www.docker.com/products/docker-desktop)
* [Terraform CLI](https://developer.hashicorp.com/terraform/downloads)

## Installation et Fichiers

Créez les trois fichiers suivants dans votre dossier de projet.

### 1. variables.tf

Ce fichier définit les entrées configurables du projet.

```hcl
variable "server_count" {
  description = "Nombre de serveurs Nginx à lancer"
  type        = number
  default     = 1
}

variable "base_port" {
  description = "Le port de départ pour l'incrémentation (ex: 8080)"
  type        = number
  default     = 8080
}

```

### 2. main.tf

Ce fichier contient la logique principale et l'appel aux providers.

```hcl
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

resource "docker_container" "app_server" {
  # Boucle pour créer plusieurs instances
  count = var.server_count
  
  image = docker_image.nginx.image_id
  name  = "server-web-${count.index + 1}"

  ports {
    internal = 80
    # Calcul dynamique du port : 8080, 8081, 8082...
    external = var.base_port + count.index 
  }
}

```

### 3. outputs.tf

Ce fichier formate les informations retournées à la fin de l'exécution.

```hcl
output "server_names" {
  value       = docker_container.app_server[*].name
  description = "Liste des noms des conteneurs déployés"
}

output "access_urls" {
  value       = [for i in range(var.server_count) : "http://localhost:${var.base_port + i}"]
  description = "Liste des URLs d'accès générées dynamiquement"
}

```

---

## Scénario d'Utilisation (5 min)

### Étape 1 : Déploiement Initial

Initialisez le projet et lancez une instance par défaut (comme défini dans `variables.tf`).

```bash
terraform init
terraform apply
# Validez avec 'yes'

```

**Résultat :** Terraform déploie 1 serveur sur le port 8080. Les "Outputs" affichent l'URL d'accès.

### Étape 2 : Scale UP (Montée en charge)

Simulez un pic de trafic nécessitant 5 serveurs instantanément. Nous surchargeons la variable `server_count` directement en ligne de commande.

```bash
terraform apply -var="server_count=5"

```

**Observation :**

* Terraform détecte que le serveur 1 existe déjà (il ne le touche pas).
* Il planifie la création de 4 nouveaux serveurs.
* Il calcule automatiquement les ports (8081 à 8084).

Validez avec `yes`.

**Vérification :**
Utilisez la commande `docker ps` pour voir les 5 conteneurs actifs ou cliquez sur les liens affichés dans la section `Outputs`.

### Étape 3 : Scale DOWN (Réduction)

Le trafic diminue, revenez à une configuration minimale de 2 serveurs pour économiser les ressources.

```bash
terraform apply -var="server_count=2"

```

**Observation :** Terraform comprend qu'il doit détruire les serveurs 3, 4 et 5, et conserver les serveurs 1 et 2.

### Étape 4 : Nettoyage

Supprimez l'ensemble de l'infrastructure créée.

```bash
terraform destroy --auto-approve

```
