module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.7.3"

  cluster_name                = "ecs-cluster-${local.name}"
  create_cloudwatch_log_group = true

  cluster_settings = { "name" : "containerInsights", "value" : "disabled" }

  services = {
    phppgadmin = {

      cpu    = 512
      memory = 1024

      # Container definition(s)
      container_definitions = {
        phppgadmin = {
          name   = "phppgadmin"
          cpu    = 512
          memory = 1024
          #https://github.com/dockersamples/spring-petclinic-docker
          image = "bitnami/phppgadmin-archived"
          port_mappings = [
            {
              name          = "container"
              containerPort = local.container_port
              protocol      = "tcp"
            }
          ]

          environment = [
            { "name" : "DATABASE_ENABLE_EXTRA_LOGIN_SECURITY", value : "yes" },
            { "name" : "DATABASE_HOST", value : module.db.db_instance_address },
            { "name" : "DATABASE_SSL_MODE", value : "require" },
            { "name" : "PHPPGADMIN_URL_PREFIX", value : "demo" }
          ]

          # Example image used requires access to write to root filesystem
          readonly_root_filesystem  = false
          enable_cloudwatch_logging = true

          memory_reservation = 100
        }
      }

      load_balancer = {
        service = {
          target_group_arn = module.alb.target_groups.ecs.arn
          container_name   = "phppgadmin"
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
