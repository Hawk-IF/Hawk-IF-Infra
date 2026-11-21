variable "install_docker" {
  description = "Define se o Docker será instalado."
  type        = bool
  default     = true
}

variable "install_docker_buildx" {
  description = "Define se o Docker Buildx será instalado."
  type        = bool
  default     = true

  validation {
    condition = (
      !var.install_docker_buildx || var.install_docker
    )

    error_message = "Para instalar Docker Buildx, install_docker também deve ser true."
  }
}

variable "install_docker_compose" {
  description = "Define se o Docker Compose será instalado."
  type        = bool
  default     = true

  validation {
    condition = (
      !var.install_docker_compose || var.install_docker
    )

    error_message = "Para instalar Docker Compose, install_docker também deve ser true."
  }
}
