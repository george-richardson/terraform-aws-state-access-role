
data "aws_iam_policy_document" "trust" {
  source_policy_documents   = var.trust_policy_source_policy_documents
  override_policy_documents = var.trust_policy_override_policy_documents

  dynamic "statement" {
    for_each = var.trusted_aws_principals
    content {
      sid     = coalesce(statement.value.sid, "aws${statement.key}")
      actions = ["sts:AssumeRole"]

      principals {
        type        = "AWS"
        identifiers = statement.value.principals
      }

      dynamic "condition" {
        for_each = length(statement.value.principal_condition_filters) > 0 ? ["create"] : []
        content {
          test     = "ArnLike"
          variable = "aws:PrincipalArn"
          values   = statement.value.principal_condition_filters
        }
      }

      dynamic "condition" {
        for_each = length(statement.value.org_paths_condition_filters) > 0 ? ["create"] : []
        content {
          test     = "ForAnyValue:StringLike"
          variable = "aws:PrincipalOrgPaths"
          values   = statement.value.org_paths_condition_filters
        }
      }
    }
  }

  dynamic "statement" {
    for_each = var.trusted_github_oidc_principals
    content {
      sid     = coalesce(statement.value.sid, "github-${statement.key}")
      actions = ["sts:AssumeRoleWithWebIdentity"]

      principals {
        type        = "Federated"
        identifiers = [statement.value.oidc_provider_arn]
      }

      condition {
        test     = "StringEquals"
        variable = "token.actions.githubusercontent.com:aud"
        values   = [statement.value.aud]
      }

      condition {
        test     = "StringLike"
        variable = "token.actions.githubusercontent.com:sub"
        values   = statement.value.sub_filters
      }
    }
  }
}
