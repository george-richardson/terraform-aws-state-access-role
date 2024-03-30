variable "state_bucket_arn" {
  type        = string
  description = "The ARN of the S3 bucket where the state files are stored."
}

variable "state_bucket_kms_key_arn" {
  type        = string
  description = "The ARN of the KMS key used to encrypt the state files."
  default     = null
}

variable "lock_table_arn" {
  type        = string
  description = "The ARN of the DynamoDB table used for state locking. If not provided, only S3 permissions will be generated."
  default     = null
}

variable "lock_table_kms_key_arn" {
  type        = string
  description = "The ARN of the KMS key used to encrypt the lock table."
  default     = null
}

variable "allow_full_bucket_list" {
  type        = bool
  description = "Whether to allow the role to list all objects in the state bucket rather than just those needed by workspace definitions. This can be useful for reducing the size of the generated policy."
  default     = false
}

variable "can_read" {
  description = <<EOF
    Backend configurations that can be read. This does not allow locking of state, useful when using terraform_remote_state data sources.

    Fields:
    (Required) key: Path to the state file inside the S3 Bucket. Supports wildcards.
    (Optional) workspace_key_prefix: Prefix applied to the state path inside the bucket when using workspaces. Supports wildcards. Default: "env:"
    (Optional) workspaces: List of workspaces that can be accessed. Supports wildcards. Default: ["*"]
    (Optional) allow_default_workspace: Allow access to the default workspace (i.e. the value of key with no workspace_key_prefix). Default: true
  EOF
  type = list(object({
    key                     = string
    workspace_key_prefix    = optional(string, "env:")
    workspaces              = optional(list(string), ["*"])
    allow_default_workspace = optional(bool, true)
  }))
  default = []
}

variable "can_plan" {
  description = <<EOF
    Backend configurations that can be planned. State locking is allowed here for use in plans, however write access to the state bucket is prevented. 
    WARNING: principals will be able to start apply runs using these permissions, but won't be able to write changes to state. Care should be take to prevent principals from making changes to resources as well as state.

    Fields:
    (Required) key: Path to the state file inside the S3 Bucket. Supports wildcards.
    (Optional) workspace_key_prefix: Prefix applied to the state path inside the bucket when using workspaces. Supports wildcards. Default: "env:"
    (Optional) workspaces: List of workspaces that can be accessed. Supports wildcards. Default: ["*"]
    (Optional) allow_default_workspace: Allow access to the default workspace (i.e. the value of key with no workspace_key_prefix). Default: true
  EOF
  type = list(object({
    key                     = string
    workspace_key_prefix    = optional(string, "env:")
    workspaces              = optional(list(string), ["*"])
    allow_default_workspace = optional(bool, true)
  }))
  default = []
}

variable "can_apply" {
  description = <<EOF
    Backend configurations that can be applied. This allows locking of state and writing to the state bucket.

    Fields:
    (Required) key: Path to the state file inside the S3 Bucket. Supports wildcards.
    (Optional) workspace_key_prefix: Prefix applied to the state path inside the bucket when using workspaces. Supports wildcards. Default: "env:"
    (Optional) workspaces: List of workspaces that can be accessed. Supports wildcards. Default: ["*"]
    (Optional) allow_default_workspace: Allow access to the default workspace (i.e. the value of key with no workspace_key_prefix). Default: true
  EOF
  type = list(object({
    key                     = string
    workspace_key_prefix    = optional(string, "env:")
    workspaces              = optional(list(string), ["*"])
    allow_default_workspace = optional(bool, true)
  }))
  default = []
}
