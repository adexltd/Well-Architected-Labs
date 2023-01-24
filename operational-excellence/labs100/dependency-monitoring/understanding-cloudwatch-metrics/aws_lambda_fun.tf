resource "aws_lambda_function" "ec2-stop-start" {
  filename      = "lambda.zip"
  function_name = "lambda"
  role          = aws_iam_role.lambda-role.arn
  handler       = "lambda.lambda_handler"

  source_code_hash = filebase64sha256("lambda.zip")

  runtime = "python3.7"
  timeout = 63
}

resource "aws_cloudwatch_event_rule" "ec2-rule" {
  name        = "ec2-rule"
  description = "Trigger EC2 stop instance every 5 min"

  schedule_expression = "rate(5 minutes)"

}

resource "aws_cloudwatch_event_target" "lambda-func" {
  rule      = aws_cloudwatch_event_rule.ec2-rule.name
  target_id = "lambda"
  arn       = aws_lambda_function.ec2-stop-start.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2-stop-start.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2-rule.arn
}