resource "aws_sns_topic" "datetime_ratelimit" {
  name              = local.alarm_topic
  kms_master_key_id = module.alarm_topic_kms.key_arn
}

resource "aws_sns_topic_subscription" "datetime_ratelimit" {
  topic_arn = aws_sns_topic.datetime_ratelimit.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_sns_topic_policy" "ratelimit" {
  arn    = aws_sns_topic.datetime_ratelimit.arn
  policy = data.aws_iam_policy_document.ratelimit_alarm.json
}
