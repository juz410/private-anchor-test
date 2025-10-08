data "aws_ami" "amazon_linux" {
  owners = ["self"] # your account

  filter {
    name   = "image-id"
    values = ["ami-0e74977b5bb6af61e"]
  }
}

data "aws_kms_key" "cloudwatch_logs_cmk" {
  key_id = "alias/anchor-testbed-cloudwatch-logs-kms-001"
}