module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.7.3"

  cluster_name                = "ecs-cluster-${local.name}"
  create_cloudwatch_log_group = false

  cluster_settings = { "name" : "containerInsights", "value" : "disabled" }

  services = {
    container = {
      cpu    = 512
      memory = 1024

      # Container definition(s)
      container_definitions = {

        container = {
          cpu    = 512
          memory = 1024
          image  = "pietervincken/snake-server:0.0.2"
          port_mappings = [
            {
              name          = "container"
              containerPort = local.container_port
              protocol      = "tcp"
            }
          ]

          # Example image used requires access to write to root filesystem
          readonly_root_filesystem  = true
          enable_cloudwatch_logging = false

          memory_reservation = 100
        }
      }

      load_balancer = {
        service = {
          target_group_arn = module.alb.target_groups.ecs.arn
          container_name   = "container"
          container_port   = local.container_port
        }
      }

      subnet_ids = module.vpc.private_subnets
      security_group_rules = {
        alb_ingress = {
          type                     = "ingress"
          from_port                = local.container_port
          to_port                  = local.container_port
          protocol                 = "tcp"
          description              = "Service port"
          source_security_group_id = module.alb.security_group_id
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }

  tags = local.tags
}
