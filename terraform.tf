provider "aws" {
  region                   = "us-west-1"
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
}

provider "archive" {}

data "archive_file" "lambda_file" {
  type        = "zip"
  output_path = "./.terraform-temp/lambda.zip"
  source_file = "./index.js"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

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



resource "aws_lambda_function" "test_function" {
  function_name = "function_test_node"

  runtime = "nodejs16.x"

  role = aws_iam_role.iam_for_lambda.arn

  filename = data.archive_file.lambda_file.output_path
  handler  = "index.handler"
}

resource "aws_lambda_function_url" "url" {
  function_name      = aws_lambda_function.test_function.arn
  authorization_type = "NONE"
}

output "lambda_url" {
  value = aws_lambda_function_url.url.function_url
}

