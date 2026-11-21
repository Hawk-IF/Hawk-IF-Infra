variable "project_name" {
  description = "Nome do projeto."
  type        = string
}

variable "environment" {
  description = "Ambiente de execução."
  type        = string
}

variable "env_file_docker_resources_path" {
  description = "Caminho do arquivo de variáveis relacionado aos recursos do docker e utilizado pelo Docker Compose."
  type        = string
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