locals {
    project_root = abspath("${path.root}/../../..")

    environments_path = "${local.project_root}/environments"

    env_file_docker_resources_path = "${local.environments_path}/local-docker-resources.env"
}