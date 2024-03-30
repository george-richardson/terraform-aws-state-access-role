resource "aws_iam_role" "this" {
  name               = var.name
  path               = var.path
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

data "aws_iam_policy_document" "trust" {
  source_policy_documents = [var.trust_policy]
}

resource "aws_iam_role_policy" "inline_policy" {
  name   = "terraform-state-access"
  role   = aws_iam_role.this.name
  policy = module.permissions_policy.json
}

module "permissions_policy" {
  source = "./modules/permissions-policy"

  state_bucket_arn         = var.state_bucket_arn
  state_bucket_kms_key_arn = var.state_bucket_kms_key_arn
  lock_table_arn           = var.lock_table_arn
  lock_table_kms_key_arn   = var.lock_table_kms_key_arn
  allow_full_bucket_list   = var.allow_full_bucket_list

  can_read  = var.can_read
  can_plan  = var.can_plan
  can_apply = var.can_apply
}
