locals {
  project_prefix = "${var.project_name}-${var.environment}"

  scripts_path = "${path.module}/scripts"
  deploy_script_path = "${local.scripts_path}/00-deploy.sh"
  destroy_script_path = "${local.scripts_path}/00-destroy.sh"
}