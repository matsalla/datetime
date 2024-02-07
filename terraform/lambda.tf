module "date_bucket_lambda" {
  depends_on                        = [module.lambda_log_group]
  source                            = "terraform-aws-modules/lambda/aws"
  function_name                     = local.lambda_function
  description                       = "Uploads a file with current datetime contents to an S3 bucket"
  handler                           = "update_date_file.lambda_handler"
  runtime                           = "python3.11"
  publish                           = true
  logging_log_format                = "JSON"
  logging_application_log_level     = "INFO"
  logging_system_log_level          = "WARN"
  use_existing_cloudwatch_log_group = true
  logging_log_group                 = module.lambda_log_group.cloudwatch_log_group_name
  attach_policy_jsons               = true
  number_of_policy_jsons            = 2
  policy_jsons = [
    data.aws_iam_policy_document.lambda_bucket_kms_access.json,
    data.aws_iam_policy_document.lambda_bucket_access.json
  ]
  allowed_triggers = {
    crons = {
      principal  = "events.amazonaws.com"
      source_arn = module.date_bucket_event.eventbridge_rule_arns.crons
    }
  }
  source_path = "../src/update_date_file.py"
}

data "aws_iam_policy_document" "lambda_bucket_access" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${module.date_bucket_s3.s3_bucket_arn}/${local.s3_key}"]
  }
}

data "aws_iam_policy_document" "lambda_bucket_kms_access" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]
    resources = [module.date_bucket_kms.key_arn]
  }
}

module "lambda_log_group" {
  depends_on        = [module.cloudwatch_logs_kms]
  source            = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  name              = local.lambda_logs
  skip_destroy      = false
  retention_in_days = 7
  kms_key_id        = module.cloudwatch_logs_kms.key_arn
}
