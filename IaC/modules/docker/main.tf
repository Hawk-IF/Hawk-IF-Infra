resource "docker_network" "backend_gateway_network" {
  name = local.backend_gateway_network
}

resource "docker_network" "frontend_gateway_network" {
  name = local.frontend_gateway_network
}

resource "docker_network" "backend_network" {
  name = local.backend_network
}

resource "docker_volume" "database" {
  name = local.database_volume
}

resource "docker_volume" "redis" {
  name = local.redis_volume
}

resource "local_file" "docker_env" {
  filename = var.env_file_docker_resources_path
  content  = local.docker_env_content
}
