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
