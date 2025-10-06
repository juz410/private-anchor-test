data "aws_ami" "amazon_linux" {
  owners = ["self"] # your account

  filter {
    name   = "image-id"
    values = ["ami-0e74977b5bb6af61e"]
  }
}
