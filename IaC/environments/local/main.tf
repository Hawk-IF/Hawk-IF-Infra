module "dependencies" {
  source = "../../modules/dependencies"

  install_docker = var.install_docker
  install_docker_buildx = var.install_docker_buildx
  install_docker_compose = var.install_docker_compose
}

module "docker" {
  source = "../../modules/docker"

  project_name         = var.project_name
  environment          = var.environment
  env_file_docker_resources_path = local.env_file_docker_resources_path

  depends_on = [module.dependencies]
}

module "application" {
  source = "../../modules/application"

  project_name         = var.project_name
  environment          = var.environment
  env_file_docker_resources_path = local.env_file_docker_resources_path
  postgres_db = var.postgres_db
  postgres_user = var.postgres_user
  postgres_password = var.postgres_password
  redis_password = var.redis_password
  nginx_port = var.nginx_port

  depends_on = [ module.docker ]
}
