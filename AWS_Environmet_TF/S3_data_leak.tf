# S3 bucket for data storage
resource "aws_s3_bucket" "data_bucket" {
  bucket = "chatbot-data-bucket"
}