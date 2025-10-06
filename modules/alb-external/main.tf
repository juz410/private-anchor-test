#target group
resource "aws_lb_target_group" "testbed_target_group" {
  name     = "${var.resource_name_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  tags     = var.tags

}

resource "aws_lb_target_group_attachment" "testbed_target_group_attachment" {
  for_each         = var.ec2_instance_ids
  target_group_arn = aws_lb_target_group.testbed_target_group.arn
  target_id        = each.value
  port             = 80
}

resource "aws_lb" "external_alb" {
  name               = "${var.resource_name_prefix}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids
  tags               = var.tags

}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.external_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.testbed_target_group.arn
  }
}

# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.external_alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = var.ssl_cert_arn  # ACM cert ARN goes here

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.testbed_target_group.arn
#   }
# }


#waf
# Create a WAFv2 Web ACL
resource "aws_wafv2_web_acl" "alb_waf" {
  name        = "${var.resource_name_prefix}-alb-waf"
  description = "WAF for External ALB"
  scope       = "REGIONAL" # must be REGIONAL for ALBs, CLOUDFRONT for CF distributions

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.resource_name_prefix}-alb-waf-metric"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "awsCommonRules"
      sampled_requests_enabled   = true
    }
  }
}

# Associate WAF Web ACL with ALB
resource "aws_wafv2_web_acl_association" "alb_waf_assoc" {
  resource_arn = aws_lb.external_alb.arn
  web_acl_arn  = aws_wafv2_web_acl.alb_waf.arn
}

