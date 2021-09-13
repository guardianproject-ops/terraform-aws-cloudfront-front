module "aws_cloudfront_front_label" {
  source   = "cloudposse/label/null"
  version = "0.25.0"

  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  attributes = var.attributes
  delimiter  = var.delimiter
  tags = var.tags
}

resource "aws_cloudfront_distribution" "front" {
  enabled = var.enabled
  default_cache_behavior {
    cache_policy_id = aws_cloudfront_cache_policy.front_cache_policy.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.front_origin_request_policy.id
    compress = true
    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = "${module.aws_cloudfront_front_label.id}-origin"
    viewer_protocol_policy = "redirect-to-https"
  }
  origin {
    domain_name = var.origin_domain_name
    origin_id = "${module.aws_cloudfront_front_label.id}-origin"
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  is_ipv6_enabled = true
  comment = module.aws_cloudfront_front_label.id
  tags = module.aws_cloudfront_front_label.tags
}

resource "aws_cloudfront_cache_policy" "front_cache_policy" {
  name        = "${module.aws_cloudfront_front_label.id}-cache-policy"
  comment     = "Pass-through custom origin"
  default_ttl = 0
  max_ttl     = 0
  min_ttl     = 0
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "front_origin_request_policy" {
  name        = "${module.aws_cloudfront_front_label.id}-origin-request-policy"
  comment     = "Pass-through custom origin"
  cookies_config {
    cookie_behavior = "all"
  }
  headers_config {
    header_behavior = "allViewer"
  }
  query_strings_config {
    query_string_behavior = "all"
  }
}