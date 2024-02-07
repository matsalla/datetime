resource "aws_cloudwatch_metric_alarm" "ratelimit" {
  alarm_name          = local.datetime_alarm
  alarm_description   = "Check if rate limit is ever exceed on DateTime object"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = 10
  statistic           = "Sum"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.datetime_ratelimit.arn]
  dimensions = {
    WebACL = "datetimeratelimit",
    Rule   = "datetimeratelimit"
  }
  treat_missing_data = "notBreaching"
}

data "aws_iam_policy_document" "ratelimit_alarm" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.datetime_ratelimit.arn]
  }
}
