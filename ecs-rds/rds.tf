module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.3.0"

  identifier = local.name

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "13"
  family               = "postgres13" # DB parameter group
  major_engine_version = "13"         # DB option group
  instance_class       = "db.t4g.large"

  allocated_storage     = 5
  max_allocated_storage = 10

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name  = "db${local.name}"
  username = "user${local.name}"

  port = 5432

  db_subnet_group_name = module.vpc.database_subnet_group

  vpc_security_group_ids = [
    aws_security_group.ecs_to_rds.id
  ]

  create_cloudwatch_log_group = false

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  tags = local.tags
  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
}

resource "aws_security_group" "ecs_to_rds" {
  name        = "ecs-to-rds"
  description = "allow ECS to reach RDS"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "ecs_to_rds"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_to_rds" {
  security_group_id = aws_security_group.ecs_to_rds.id

  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "TCP"
  referenced_security_group_id = module.ecs.services["phppgadmin"].security_group_id

  tags = {
    "Name" = "ECS to RDS"
  }
}
