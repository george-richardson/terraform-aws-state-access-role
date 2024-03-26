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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_arn.state_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/arn) | data source |
| [aws_iam_policy_document.permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_full_bucket_list"></a> [allow\_full\_bucket\_list](#input\_allow\_full\_bucket\_list) | Whether to allow the role to list all objects in the state bucket rather than just those needed by workspace definitions. This can be useful for reducing the size of the generated policy. | `bool` | `false` | no |
| <a name="input_can_apply"></a> [can\_apply](#input\_can\_apply) | Backend configurations that can be applied. This allows locking of state and writing to the state bucket.<br><br>    Fields:<br>    (Required) key: Path to the state file inside the S3 Bucket. Supports wildcards.<br>    (Optional) workspace\_key\_prefix: Prefix applied to the state path inside the bucket when using workspaces. Supports wildcards. Default: "env:"<br>    (Optional) workspaces: List of workspaces that can be accessed. Supports wildcards. Default: ["*"]<br>    (Optional) allow\_default\_workspace: Allow access to the default workspace (i.e. the value of key with no workspace\_key\_prefix). Default: true | <pre>list(object({<br>    key                     = string<br>    workspace_key_prefix    = optional(string, "env:")<br>    workspaces              = optional(list(string), ["*"])<br>    allow_default_workspace = optional(bool, true)<br>  }))</pre> | `[]` | no |
| <a name="input_can_plan"></a> [can\_plan](#input\_can\_plan) | Backend configurations that can be planned. State locking is allowed here for use in plans, however write access to the state bucket is prevented. <br>    WARNING: principals will be able to start apply runs using these permissions, but won't be able to write changes to state. Care should be take to prevent principals from making changes to resources as well as state.<br><br>    Fields:<br>    (Required) key: Path to the state file inside the S3 Bucket. Supports wildcards.<br>    (Optional) workspace\_key\_prefix: Prefix applied to the state path inside the bucket when using workspaces. Supports wildcards. Default: "env:"<br>    (Optional) workspaces: List of workspaces that can be accessed. Supports wildcards. Default: ["*"]<br>    (Optional) allow\_default\_workspace: Allow access to the default workspace (i.e. the value of key with no workspace\_key\_prefix). Default: true | <pre>list(object({<br>    key                     = string<br>    workspace_key_prefix    = optional(string, "env:")<br>    workspaces              = optional(list(string), ["*"])<br>    allow_default_workspace = optional(bool, true)<br>  }))</pre> | `[]` | no |
| <a name="input_can_read"></a> [can\_read](#input\_can\_read) | Backend configurations that can be read. This does not allow locking of state, useful when using terraform\_remote\_state data sources.<br><br>    Fields:<br>    (Required) key: Path to the state file inside the S3 Bucket. Supports wildcards.<br>    (Optional) workspace\_key\_prefix: Prefix applied to the state path inside the bucket when using workspaces. Supports wildcards. Default: "env:"<br>    (Optional) workspaces: List of workspaces that can be accessed. Supports wildcards. Default: ["*"]<br>    (Optional) allow\_default\_workspace: Allow access to the default workspace (i.e. the value of key with no workspace\_key\_prefix). Default: true | <pre>list(object({<br>    key                     = string<br>    workspace_key_prefix    = optional(string, "env:")<br>    workspaces              = optional(list(string), ["*"])<br>    allow_default_workspace = optional(bool, true)<br>  }))</pre> | `[]` | no |
| <a name="input_lock_table_arn"></a> [lock\_table\_arn](#input\_lock\_table\_arn) | The ARN of the DynamoDB table used for state locking. If not provided, only S3 permissions will be generated. | `string` | `null` | no |
| <a name="input_state_bucket_arn"></a> [state\_bucket\_arn](#input\_state\_bucket\_arn) | The ARN of the S3 bucket where the state files are stored. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_json"></a> [json](#output\_json) | The JSON representation of the permissions policy. |
<!-- END_TF_DOCS -->