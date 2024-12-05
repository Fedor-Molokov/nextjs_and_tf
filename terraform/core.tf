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
    prevent_destroy = true
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
