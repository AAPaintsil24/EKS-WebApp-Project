# provider "aws" {
#   region = "eu-north-1"
# }

# resource "aws_s3_bucket" "tf_backend" {
#   bucket = "my-terraform-backend-albert"
# }

# resource "aws_dynamodb_table" "tf_lock" {
#   name         = "terraform-locks"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }
