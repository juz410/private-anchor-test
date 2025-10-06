output "ec2_instances_role_arn" {
  value = aws_iam_role.ec2_instance_role.arn
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_instance_profile.name
}