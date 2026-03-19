resource "aws_ecs_cluster" "this" {
  count = var.create_cluster ? 1 : 0

  name = local.cluster_name

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = merge(local.common_tags, var.cluster_tags, {
    Name = local.cluster_name
  })
}
