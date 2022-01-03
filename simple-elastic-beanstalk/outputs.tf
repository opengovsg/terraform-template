output "eb_endpoint" {
  value = module.elastic_beanstalk_environment.endpoint
}

output "db_endpoint" {
  value = module.db.db_instance_endpoint
}
output "db_port" {
  value = module.db.db_instance_port
}

output "db_schema_name" {
  value = module.db.db_instance_name
}

output "db_master_username" {
  value = module.db.db_instance_username
}
output "db_master_password" {
  value = module.db.db_master_password
}