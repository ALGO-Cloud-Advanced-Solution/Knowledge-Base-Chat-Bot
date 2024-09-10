resource "aws_iam_role" "lambda_1_role" {
  name = "${var.API_LAMBDA_1}_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda
resource "aws_iam_role_policy" "lambda_1_policy" {
  name = "${var.API_LAMBDA_1}_role"
  role = aws_iam_role.lambda_1_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "logs:*",
          "lambda:*"
        ]
        Resource = "*"
      }
    ]
  })
}
