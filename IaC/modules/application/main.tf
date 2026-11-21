resource "terraform_data" "runtime" {
  provisioner "local-exec" {
    command = "bash ${local.deploy_script_path}"

    environment = {
      PROJECT_NAME   = var.project_name
      ENVIRONMENT    = var.environment
      PROJECT_PREFIX = local.project_prefix

      # Arquivo de recursos Docker
      ENV_FILE_DOCKER_RESOURCES_PATH = var.env_file_docker_resources_path

      # PostgreSQL
      POSTGRES_DB       = var.postgres_db
      POSTGRES_USER     = var.postgres_user
      POSTGRES_PASSWORD = var.postgres_password

      # Redis
      REDIS_PASSWORD = var.redis_password

      # Nginx
      NGINX_PORT = var.nginx_port
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "bash ${self.input.destroy_script_path}"

    environment = {
      PROJECT_NAME   = self.input.project_name
      ENVIRONMENT    = self.input.environment
      PROJECT_PREFIX = self.input.project_prefix

      ENV_FILE_DOCKER_RESOURCES_PATH = self.input.env_file_docker_resources_path
    }
  }

  input = {
    destroy_script_path            = local.destroy_script_path
    env_file_docker_resources_path = var.env_file_docker_resources_path

    project_name   = var.project_name
    environment    = var.environment
    project_prefix = local.project_prefix
  }
}