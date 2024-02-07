
module "date_bucket_event" {
  source     = "terraform-aws-modules/eventbridge/aws"
  create_bus = false
  rules = {
    crons = {
      description         = "Trigger update S3 object Lambda"
      schedule_expression = "rate(10 minutes)"
    }
  }
  targets = {
    crons = [
      {
        name  = "update_date_bucket_object"
        arn   = module.date_bucket_lambda.lambda_function_arn
        input = jsonencode({ "Bucket" : local.bucket_id, "Key" : local.s3_key })
      }
    ]
  }
}
