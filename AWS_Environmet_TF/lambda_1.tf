
data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/python_function/"
  output_path = "${path.module}/python_function/app_1.zip"
}


resource "aws_lambda_function" "sabry_orchest" {
  function_name = var.API_LAMBDA_1
  role          = aws_iam_role.lambda_1_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  filename      = "function.zip"

}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sabry_orchest.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}