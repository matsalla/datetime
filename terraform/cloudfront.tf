resource "aws_cloudfront_origin_access_control" "cdn" {
  name                              = "date_time_cdn_oac"
  description                       = "date time oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cdn" {
  depends_on          = [module.date_bucket_s3]
  enabled             = true
  default_root_object = local.s3_key
  web_acl_id          = aws_wafv2_web_acl.datetime.arn
  origin {
    origin_id                = "${local.bucket_id}-origin"
    domain_name              = "${local.bucket_id}.s3.amazonaws.com"
    origin_access_control_id = aws_cloudfront_origin_access_control.cdn.id
  }
  default_cache_behavior {
    min_ttl          = 0
    default_ttl      = 30
    max_ttl          = 60
    target_origin_id = "${local.bucket_id}-origin"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
