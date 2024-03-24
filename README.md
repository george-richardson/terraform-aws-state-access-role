# Terraform S3 Backend State Access Role Module

A Terraform module for creating a least privilege access role for the Terraform S3 backend, including access to state files in S3 and locking with DynamoDB.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_permissions_policy"></a> [permissions\_policy](#module\_permissions\_policy) | ./modules/permissions-policy | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.inline_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_policy_document.trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_full_bucket_list"></a> [allow\_full\_bucket\_list](#input\_allow\_full\_bucket\_list) | Whether to allow the role to list all objects in the state bucket rather than just those needed by workspace definitions. This can be useful for reducing the size of the generated policy. | `bool` | `false` | no |
| <a name="input_can_apply"></a> [can\_apply](#input\_can\_apply) | Backend configurations that can be applied. This allows locking of state and writing to the state bucket. | <pre>list(object({<br>    key                     = string<br>    workspace_key_prefix    = optional(string, "env:")<br>    workspaces              = optional(list(string), ["*"])<br>    require_workspace_usage = optional(bool, false)<br>  }))</pre> | `[]` | no |
| <a name="input_can_plan"></a> [can\_plan](#input\_can\_plan) | Backend configurations that can be planned. State locking is allowed here for use in plans, however write access to the state bucket is prevented. WARNING: principals will be able to start apply runs using these permissions, but won't be able to write changes to state. Care should be take to prevent principals from making changes to resources as well as state. | <pre>list(object({<br>    key                     = string<br>    workspace_key_prefix    = optional(string, "env:")<br>    workspaces              = optional(list(string), ["*"])<br>    require_workspace_usage = optional(bool, false)<br>  }))</pre> | `[]` | no |
| <a name="input_can_read"></a> [can\_read](#input\_can\_read) | Backend configurations that can be read. This does not allow locking of state, useful when using terraform\_remote\_state data sources. | <pre>list(object({<br>    key                     = string<br>    workspace_key_prefix    = optional(string, "env:")<br>    workspaces              = optional(list(string), ["*"])<br>    require_workspace_usage = optional(bool, false)<br>  }))</pre> | `[]` | no |
| <a name="input_lock_table_arn"></a> [lock\_table\_arn](#input\_lock\_table\_arn) | The ARN of the DynamoDB table used for state locking. If not provided, only S3 permissions will be generated. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The name for the role to be created | `string` | n/a | yes |
| <a name="input_path"></a> [path](#input\_path) | The path for the role to be created | `any` | `null` | no |
| <a name="input_state_bucket_arn"></a> [state\_bucket\_arn](#input\_state\_bucket\_arn) | The ARN of the S3 bucket where the state files are stored. | `string` | n/a | yes |
| <a name="input_trust_policy_source_policy_documents"></a> [trust\_policy\_source\_policy\_documents](#input\_trust\_policy\_source\_policy\_documents) | A list of policy documents to use as the trust relationship for the role. | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | The ARN of the IAM role. |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | The name of the IAM role. |
<!-- END_TF_DOCS -->