resource "aws_wafv2_web_acl" "datetime" {
  name        = "datetimeratelimit"
  description = "Rate limit requests"
  scope       = "CLOUDFRONT"
  default_action {
    allow {}
  }
  rule {
    name     = "RateLimit"
    priority = 10
    action {
      block {}
    }
    statement {
      rate_based_statement {
        limit              = 105
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "datetimeratelimit"
    }
  }
  visibility_config {
    sampled_requests_enabled   = true
    cloudwatch_metrics_enabled = true
    metric_name                = "datetimeratelimit"
  }
}
