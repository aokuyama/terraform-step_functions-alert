resource "aws_lambda_function" "app" {
  function_name    = var.function_name
  publish          = false
  memory_size      = 128
  timeout          = 3
  package_type     = "Zip"
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.app.output_path
  source_code_hash = data.archive_file.app.output_base64sha256
  runtime          = "ruby2.7"
  role             = aws_iam_role.iam_for_lambda.arn
  layers           = []
  environment {
    variables = {
      SLACK_HOOK_URL = var.slack_hook_url
    }
  }
}
resource "aws_iam_role" "iam_for_lambda" {
  path = "/service-role/"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "lambda.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  managed_policy_arns = [
    aws_iam_policy.policy_for_lambda.arn,
  ]
}
resource "aws_iam_policy" "policy_for_lambda" {
  path = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action   = "logs:CreateLogGroup"
          Effect   = "Allow"
          Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.self.account_id}:*"
        },
        {
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:logs:${var.region}:${data.aws_caller_identity.self.account_id}:log-group:/aws/lambda/${var.function_name}:*",
          ]
        },
      ]
      Version = "2012-10-17"
    }
  )
}
data "archive_file" "app" {
  type        = "zip"
  source_dir  = "app"
  output_path = "tmp/app.zip"
}
