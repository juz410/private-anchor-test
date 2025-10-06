output "external_alb_sg_id" {
  description = "ID of the External ALB security group"
  value       = module.external_alb_sg.security_group_id
}

output "external_alb_sg_arn" {
  description = "ARN of the External ALB security group"
  value       = module.external_alb_sg.security_group_arn
}

output "uat_server_sg_id" {
  description = "ID of the UAT Server security group"
  value       = module.uat_server_sg.security_group_id
}

output "uat_server_sg_arn" {
  description = "ARN of the UAT Server security group"
  value       = module.uat_server_sg.security_group_arn
}

output "all_in_one_server_sg_id" {
  description = "ID of the All-in-One Server security group"
  value       = module.all_in_one_server_sg.security_group_id
}

output "all_in_one_server_sg_arn" {
  description = "ARN of the All-in-One Server security group"
  value       = module.all_in_one_server_sg.security_group_arn
}

output "interface_endpoint_sg_id" {
  description = "ID of the Interface Endpoint security group"
  value       = module.interface_endpoint_sg.security_group_id
}

output "interface_endpoint_sg_arn" {
  description = "ARN of the Interface Endpoint security group"
  value       = module.interface_endpoint_sg.security_group_arn
}
