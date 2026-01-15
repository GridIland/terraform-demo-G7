variable "server_count" {
  description = "Nombre de serveurs Nginx à lancer"
  type        = number
  default     = 1
}

variable "base_port" {
  description = "Le port de départ (ex: 8080, 8081...)"
  type        = number
  default     = 8080
}
