module "date_bucket_kms" {
  source                  = "terraform-aws-modules/kms/aws"
  description             = "KMS key for S3 Bucket"
  key_usage               = "ENCRYPT_DECRYPT"
  aliases                 = ["datebucket"]
  source_policy_documents = [data.aws_iam_policy_document.cloudfront1.json]
}

data "aws_iam_policy_document" "cloudfront1" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudfront::${local.account_id}:distribution/*"]
    }
  }
}

module "cloudwatch_logs_kms" {
  source                  = "terraform-aws-modules/kms/aws"
  description             = "KMS key Lambda Log Group"
  key_usage               = "ENCRYPT_DECRYPT"
  aliases                 = ["timestamp_function"]
  source_policy_documents = [data.aws_iam_policy_document.lambda_logging.json]
}

data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${local.region}:${local.account_id}:log-group:${local.lambda_logs}"]
    }
  }
}

module "alarm_topic_kms" {
  source                  = "terraform-aws-modules/kms/aws"
  description             = "KMS key alarm SNS topic"
  key_usage               = "ENCRYPT_DECRYPT"
  aliases                 = ["alarm_topic"]
  source_policy_documents = [data.aws_iam_policy_document.alarm_topic.json]
}

data "aws_iam_policy_document" "alarm_topic" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudwatch:${local.region}:${local.account_id}:alarm:${local.datetime_alarm}"]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:EncryptionContext:aws:sns:topicArn"
      values   = ["arn:aws:sns:${local.region}:${local.account_id}:${local.alarm_topic}"]
    }
  }
}
