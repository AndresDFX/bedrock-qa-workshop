provider "aws" {
  region = "us-east-1" # Región recomendada para disponibilidad de Bedrock
}

# 1. Empaquetar el código Python de la carpeta src/
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/src/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

# 2. Rol de IAM y Permisos para Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "BedrockQA_LambdaRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "bedrock_access" {
  name = "BedrockInvokePolicy"
  role = aws_iam_role.lambda_exec_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["bedrock:InvokeModel"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# 3. Función Lambda
resource "aws_lambda_function" "qa_agent" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "QAAgentFunction"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  timeout       = 30 # Vital: Dale tiempo a la IA para responder
  
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# 4. API Gateway (HTTP API)
resource "aws_apigatewayv2_api" "http_api" {
  name          = "QAAgentAPI"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.qa_agent.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "api_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /analyze-bug"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.qa_agent.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# 5. Output de la URL
output "api_endpoint" {
  value       = "${aws_apigatewayv2_api.http_api.api_endpoint}/analyze-bug"
  description = "URL para invocar el asistente de QA"
}