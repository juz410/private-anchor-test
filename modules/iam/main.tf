# IAM Role for EC2
resource "aws_iam_role" "ec2_instance_role" {
  name = "${var.resource_name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# Attach SSM Core policy
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach CloudWatch Agent policy
resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Instance Profile (required for EC2 to actually use the role)
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.resource_name_prefix}-ec2-instance-profile"
  role = aws_iam_role.ec2_instance_role.name
}
