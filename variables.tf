variable "aws_region" {
  default = "eu-north-1"
}

variable "bucket_name" {
  default = "nextjs-static-assets"
}

variable "lambda_execution_role_arn" {
  default = "arn:aws:iam::120569610851:role/MyLambdaRole"
}