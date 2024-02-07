output "curl" {
  value = "curl https://${aws_cloudfront_distribution.cdn.domain_name}/"
}
