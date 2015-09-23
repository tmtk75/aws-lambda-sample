variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" { default = "ap-northeast-1" }
# Please configure as your env
variable "prefix"      { default = "a-prefix-you-like" }
variable "bucket_name" { default = "lambda-test-bucket.yourdomain" }

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region     = "${var.aws_region}"
}

resource "aws_iam_role" "iam-for-lambda-test" {
    name = "${var.prefix}-iam-for-lambda-test"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "test-for-lambda" {
    name = "${var.prefix}-for-lambda-test"
    role = "${aws_iam_role.iam-for-lambda-test.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:PutLogEvents",
        "s3:List*",
        "s3:Get*",
        "s3:Put*"
      ],
      "Resource": [
        "arn:aws:logs:*:*:*",
        "arn:aws:s3:::${var.bucket_name}",
        "arn:aws:s3:::${var.bucket_name}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_lambda_function" "s3-lambda" {
    filename = "lambda-funcs.zip"
    function_name = "s3-lambda"
    description = "test for lambda function to access s3"
    role = "${aws_iam_role.iam-for-lambda-test.arn}"
    handler = "s3-obj.handler"
}

resource "aws_s3_bucket" "bkt" {
    bucket = "${var.bucket_name}"
    acl = "private"
    tags {
        Name = "${var.bucket_name}"
    }
}

output "bucket.id" { value = "${aws_s3_bucket.bkt.id}" }
output "lambda.arn" { value = "${aws_lambda_function.s3-lambda.arn}" }

