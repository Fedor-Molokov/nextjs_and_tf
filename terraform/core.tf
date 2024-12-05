resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "static_assets" {
  bucket = "${var.bucket_name}-${random_id.suffix.hex}"
  acl    = "private"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  lifecycle {
    # prevent_destroy = true
  }

  cors_rule {
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    allowed_headers = ["*"]
  }
}

resource "aws_lambda_function" "server_function" {
  function_name = "nextjs-server-function"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  role          = var.lambda_execution_role_arn

  filename         = "../out/server-functions.zip"
  source_code_hash = filebase64sha256("../out/server-functions.zip")

  environment {
    variables = {
      NODE_ENV = "sobes"
    }
  }
}

resource "aws_lambda_function" "image_optimization_function" {
  function_name = "nextjs-image-optimization"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  role          = var.lambda_execution_role_arn

  filename         = "../out/image-optimization-function.zip"
  source_code_hash = filebase64sha256("../out/image-optimization-function.zip")

  environment {
    variables = {
      NODE_ENV = "sobes"
    }
  }
}

###

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Access Identity for CloudFront"
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled = true

  origin {
    domain_name = aws_s3_bucket.static_assets.bucket_regional_domain_name
    origin_id   = "s3-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = aws_lambda_function.server_function.invoke_arn
    origin_id   = "lambda-origin-server-function"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name = aws_lambda_function.image_optimization_function.invoke_arn
    origin_id   = "lambda-origin-image-optimization-function"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern     = "/public/*"
    target_origin_id = "s3-origin"

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
        query_string = false
        cookies {
        forward = "none"
        }
    }
  }

  ordered_cache_behavior {
    path_pattern     = "/_next/static/*"
    target_origin_id = "s3-origin"

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
        query_string = false
        cookies {
        forward = "none"
        }
    }
  }

  ordered_cache_behavior {
    path_pattern     = "/*"
    target_origin_id = "lambda-origin-server-function"

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "POST", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
        query_string = true
        cookies {
        forward = "all"
        }
    }
    }
  
  ordered_cache_behavior {
    path_pattern     = "/api/*"
    target_origin_id = "lambda-origin-server-function"

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "POST", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern     = "/_next/data/*"
    target_origin_id = "lambda-origin-server-function"

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern     = "/_next/image/*"
    target_origin_id = "lambda-origin-image-optimization-function"

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET"]
    cached_methods         = ["GET"]

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
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
}
