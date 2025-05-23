output "alb_fqdn" {
  value = module.alb.dns_name
}

output "password_arn" {
  value = module.db.db_instance_master_user_secret_arn
}

output "username" {
  sensitive = true
  value     = module.db.db_instance_username
}

output "db_public_fqdn" {
  value = module.db.db_instance_address
}

output "db_name" {
  value = local.db_name
}