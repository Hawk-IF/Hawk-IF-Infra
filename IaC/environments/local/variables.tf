variable "project_name" {
    description = "Nome do projeto"
    type = string
}

variable "environment" {
    description = "Ambiente de execução"
    type = string
}

variable "install_docker" {
  description = "Define se o Docker será instalado."
  type        = bool
  default     = true
}

variable "install_docker_buildx" {
  description = "Define se o Docker Buildx será instalado."
  type        = bool
  default     = true
}

variable "install_docker_compose" {
  description = "Define se o Docker Compose será instalado."
  type        = bool
  default     = true
}

variable "postgres_db" {
  description = "Nome do banco de dados PostgreSQL."
  type        = string
}

variable "postgres_user" {
  description = "Usuário do PostgreSQL."
  type        = string
}

variable "postgres_password" {
  description = "Senha do PostgreSQL."
  type        = string
  sensitive   = true
}

variable "redis_password" {
  description = "Senha do Redis."
  type        = string
  sensitive   = true
}

variable "nginx_port" {
  description = "Porta de exposição do Nginx."
  type        = number
}