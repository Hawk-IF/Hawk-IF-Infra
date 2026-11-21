resource "terraform_data" "install_docker" {
  count = var.install_docker ? 1 : 0

  triggers_replace = {
    script_hash = filesha256(
      "${path.module}/scripts/install-docker.sh"
    )
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/install-docker.sh"
  }
}

resource "terraform_data" "install_docker_buildx" {
  count = var.install_docker_buildx ? 1 : 0

  triggers_replace = {
    script_hash = filesha256(
      "${path.module}/scripts/install-docker-buildx.sh"
    )
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/install-docker-buildx.sh"
  }

  depends_on = [terraform_data.install_docker]
}

resource "terraform_data" "install_docker_compose" {
  count = var.install_docker_compose ? 1 : 0

  triggers_replace = {
    script_hash = filesha256(
      "${path.module}/scripts/install-docker-compose.sh"
    )
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/install-docker-compose.sh"
  }

  depends_on = [terraform_data.install_docker]
}
