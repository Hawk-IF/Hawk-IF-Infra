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