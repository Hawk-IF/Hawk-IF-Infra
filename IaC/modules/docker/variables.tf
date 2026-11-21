variable "project_name" {
    description = "Nome do projeto"
    type = string
}

variable "environment" {
    description = "Ambiente de execução"
    type = string
}

variable "env_file_path" {
    description = "Caminho para a o arquivo com as variáveis de ambiente relacionadas aos nomes das redes e volumes"
    type = string
}