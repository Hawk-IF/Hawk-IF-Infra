locals {
    project_prefix = "${var.project_name}-${var.environment}"

    volume_sufix = "volume"
    network_sufix = "network"


    backend_gateway_network = "${local.project_prefix}-backend_gateway-${network_sufix}"
    frontend_gateway_network = "${local.project_prefix}-frontend_gateway-${network_sufix}"
    backend_network = "${local.project_prefix}-backend-${network_sufix}"

    database_volume = "${local.project_prefix}-database-${volume_sufix}"
    redis_volume = "${local.project_prefix}-redis-${volume_sufix}"


    docker_env_content = <<-EOT
        PROJECT_PREFIX=${local.project_prefix}

        BACKEND_GATEWAY_NETWORK=${local.backend_gateway_network}
        FRONTEND_GATEWAY_NETWORK=${local.frontend_gateway_network}
        BACKEND_NETWORK=${local.backend_network}

        DATABASE_VOLUME=${local.database_volume}
        REDIS_VOLUME=${local.redis_volume}
    EOT

}