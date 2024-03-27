data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_s3_bucket" "state" {
  bucket_prefix = "test-state-bucket"
}

resource "aws_dynamodb_table" "lock" {
  name         = "test-lock-table"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "trust_policy" {
  value = data.aws_iam_policy_document.trust.json
}

output "state_bucket_arn" {
  value = aws_s3_bucket.state.arn
}

output "state_bucket_name" {
  value = aws_s3_bucket.state.id
}

output "lock_table_arn" {
  value = aws_dynamodb_table.lock.arn
}
