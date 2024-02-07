module "date_bucket_s3" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = local.bucket_id
  versioning = {
    enabled = true
  }
  attach_deny_insecure_transport_policy = true
  force_destroy                         = true
  attach_policy                         = true
  policy                                = data.aws_iam_policy_document.s3.json
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = module.date_bucket_kms.key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  allowed_kms_key_arn = module.date_bucket_kms.key_arn
}

data "aws_iam_policy_document" "s3" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${local.bucket_id}/*"]
    condition {
      test     = "StringLike"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${local.account_id}:distribution/*"]
    }
  }
}

# Put an initial object in S3 to prevent waiting up to 10 minutes for event to fire
resource "aws_s3_object" "seed_object" {
  depends_on = [aws_cloudfront_distribution.cdn]
  bucket  = local.bucket_id
  key     = local.s3_key
  content = timestamp()
  lifecycle {
    ignore_changes = [ content, tags_all, tags, cache_control ]
  }
}
