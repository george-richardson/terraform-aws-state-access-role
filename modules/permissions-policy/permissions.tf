data "aws_arn" "state_bucket" {
  arn = var.state_bucket_arn
}

locals {
  state_bucket_name = data.aws_arn.state_bucket.resource

  # List of S3 prefixes to allow list operations on.
  # ListObjects (s3:ListBucket) is only used for `terraform workspace list`. 
  s3_list_prefix_filters = sort(distinct(flatten([for state_definition in concat(var.can_read, var.can_plan, var.can_apply) :
    concat(
      [state_definition.key], # Required to prevent a 403 during terraform init
      length(state_definition.workspaces) > 0 ? ["${state_definition.workspace_key_prefix}/"] : []
    )
  ])))

  # Split S3 access defitions into read and write types
  # Read and plan only require read access
  # Apply requires read and write access
  s3_state_definitions = {
    "read"  = concat(var.can_read, var.can_plan)
    "write" = var.can_apply
  }

  # Map of S3 resources to allow read/write operations on.
  # Keys are "read" or "write" as defined above.
  # Values are lists of S3 object keys.
  # e.g. {
  #   "read" = [
  #     "arn:aws:s3:::state-bucket-name/workspace-prefix/*/workspace.tfstate",
  #     "arn:aws:s3:::state-bucket-name/workspace.tfstate",
  #   ])
  #   "write" = [
  #     "arn:aws:s3:::state-bucket-name/env:/*/terraform.tfstate",
  #     "arn:aws:s3:::state-bucket-name/terraform.tfstate",
  #   ])
  # }
  s3_resources = {
    for type, state_definitions in local.s3_state_definitions : type => sort(distinct(flatten([for state_definition in state_definitions :
      concat(
        state_definition.allow_default_workspace ? ["${var.state_bucket_arn}/${state_definition.key}"] : [],
        [
          for workspace in state_definition.workspaces :
          "${var.state_bucket_arn}/${state_definition.workspace_key_prefix}/${workspace}/${state_definition.key}"
        ]
      )
    ])))
  }

  # List of leading keys to allow DynamoDB operations on for locking.
  # When locking a new item is created matching the state files path for the duration of the lock.
  # An additional "-md5" suffixed item is also created or updated for consistency checks.
  # e.g. ["state-bucket-name/terraform.tfstate", "state-bucket-name/terraform.tfstate-md5"]
  # or ["state-bucket-name/workspace-prefix/workspace/terraform.tfstate", "state-bucket-name/workspace-prefix/workspace/terraform.tfstate-md5"]
  dynamo_key_filters = sort(distinct(flatten([for state_definition in concat(var.can_apply, var.can_plan) :
    concat(
      state_definition.allow_default_workspace ? ["${local.state_bucket_name}/${state_definition.key}"] : [],
      [
        for workspace in state_definition.workspaces :
        "${local.state_bucket_name}/${state_definition.workspace_key_prefix}/${workspace}/${state_definition.key}"
      ]
    )
  ])))
}

data "aws_iam_policy_document" "permissions" {
  statement {
    sid       = "S3List"
    actions   = ["s3:ListBucket"]
    resources = [var.state_bucket_arn]

    dynamic "condition" {
      for_each = var.allow_full_bucket_list == false ? ["create"] : []
      content {
        test     = "StringLike"
        variable = "s3:prefix"
        values   = local.s3_list_prefix_filters
      }
    }
  }

  dynamic "statement" {
    for_each = length(local.s3_resources["read"]) > 0 ? ["create"] : []
    content {
      sid       = "S3Read"
      actions   = ["s3:GetObject"]
      resources = local.s3_resources["read"]
    }
  }

  dynamic "statement" {
    for_each = length(local.s3_resources["write"]) > 0 ? ["create"] : []
    content {
      sid       = "S3Write"
      actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
      resources = local.s3_resources["write"]
    }
  }

  dynamic "statement" {
    for_each = var.lock_table_arn != null && length(local.dynamo_key_filters) > 0 ? ["create"] : []
    content {
      sid       = "DynamoWrite"
      actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
      resources = [var.lock_table_arn]

      condition {
        test     = "ForAllValues:StringLike"
        variable = "dynamodb:LeadingKeys"
        values   = flatten([for filter in local.dynamo_key_filters : [filter, "${filter}-md5"]])
      }
    }
  }
}
