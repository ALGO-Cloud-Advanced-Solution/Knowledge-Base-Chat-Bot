resource "aws_api_gateway_rest_api" "api" {
  name        = "ChatbotAPI"
  description = "API Gateway integrated with Lambda for Chatbot"
}

# API Gateway Resource (Path)
resource "aws_api_gateway_resource" "_ApiGWResource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "chat"
}

# API Gateway Method (POST)
resource "aws_api_gateway_method" "_ApiGWMethod" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource._ApiGWResource.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = false
}

# API Gateway Integration Request (Lambda)
resource "aws_api_gateway_integration" "_lambdaIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource._ApiGWResource.id
  http_method             = aws_api_gateway_method._ApiGWMethod.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.sabry_orchest.invoke_arn
  timeout_milliseconds    = 29000
  passthrough_behavior    = "WHEN_NO_MATCH"
}

# API Gateway Method Response (200)
resource "aws_api_gateway_method_response" "_method_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource._ApiGWResource.id
  http_method = aws_api_gateway_method._ApiGWMethod.http_method
  status_code = "200"
}

# API Gateway Integration Response (Lambda -> API Gateway)
resource "aws_api_gateway_integration_response" "_LambdaIntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource._ApiGWResource.id
  http_method = aws_api_gateway_method._ApiGWMethod.http_method
  status_code = aws_api_gateway_method_response._method_response.status_code
}

# Deploy the API Gateway
resource "aws_api_gateway_deployment" "_deployment" {
  depends_on = [aws_api_gateway_integration._lambdaIntegration]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
}