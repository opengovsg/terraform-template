output "eb_endpoint" {
  value       = module.elastic_beanstalk_environment.endpoint
  description = "Elastic Beanstalk connection endpoint"
}

output "db_endpoint" {
  value       = module.db.db_instance_endpoint
  description = "Postgres database connection endpoint"
}
output "db_port" {
  value       = module.db.db_instance_port
  description = "Postgres database port number"
}

output "db_name" {
  value       = module.db.db_instance_name
  description = "Postgres database name"
}

output "db_security_group_id" {
  value       = module.db_security_group.security_group_id
  description = "Postgres database security group ID"
}
