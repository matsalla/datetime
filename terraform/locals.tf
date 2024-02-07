locals {
  account_id      = data.aws_caller_identity.current.account_id
  region          = data.aws_region.current.name
  s3_key          = "timestamp.html"
  lambda_function = "upload_date_file_to_s3"
  bucket_id       = "date-time-${local.account_id}-${local.region}"
  lambda_logs     = "/aws/lambda/${local.lambda_function}"
  datetime_alarm  = "DateTimeRateLimit"
  alarm_topic     = "datetime-ratelimit-alarm"
}
