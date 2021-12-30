resource "aws_cloudwatch_event_rule" "job-status_change" {
  name = var.event_rule_name
  event_pattern = jsonencode(
    {
      detail = {
        status = var.target_status
      }
      detail-type = [
        "Step Functions Execution Status Change",
      ]
      source = [
        "aws.states",
      ]
    }
  )
}

resource "aws_cloudwatch_event_target" "job-status_change-to-lambda" {
  rule = aws_cloudwatch_event_rule.job-status_change.name
  arn  = aws_lambda_function.app.arn
}

resource "aws_lambda_permission" "job-status_change" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.job-status_change.arn
}
