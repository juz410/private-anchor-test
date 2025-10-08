#################################################
## Logging - VPC Flow Logs (no TGW)
#################################################

# --- VARIABLES ---


# --- CLOUDWATCH LOG GROUP ---
# Uses the VPC Name tag dynamically for naming consistency
resource "aws_cloudwatch_log_group" "vpc_flow" {
  name              = "/vpc/flowlog/${var.vpc_name}"
  retention_in_days = var.flow_logs_retention_days
  kms_key_id        = var.flow_logs_kms_key_id

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-cwl-vpcflow"
  })
}

# --- IAM ROLE for Flow Logs to write to CloudWatch Logs ---
resource "aws_iam_role" "vpc_flowlog_role" {
  name  = "${var.vpc_name}-iam-vpcflow-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "vpc_flowlog_to_cwl" {
  name  = "${var.vpc_name}-iam-pol-vpcflow-cwl"
  role  = aws_iam_role.vpc_flowlog_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          aws_cloudwatch_log_group.vpc_flow.arn,
          "${aws_cloudwatch_log_group.vpc_flow.arn}:*"
        ]
      }
    ]
  })
}

# --- VPC FLOW LOG ---
resource "aws_flow_log" "vpc_flow" {

  vpc_id                  = var.vpc_id
  log_destination_type    = "cloud-watch-logs"
  log_destination         = aws_cloudwatch_log_group.vpc_flow.arn
  iam_role_arn            = aws_iam_role.vpc_flowlog_role.arn
  traffic_type            = var.flow_logs_traffic_type
  max_aggregation_interval = 60 # seconds (use 600 for cost efficiency)

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-vpc-flowlog"
  })

  depends_on = [
    aws_cloudwatch_log_group.vpc_flow,
    aws_iam_role_policy.vpc_flowlog_to_cwl
  ]
}
