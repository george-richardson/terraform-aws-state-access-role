# Role variables

variable "name" {
  type        = string
  description = "The name for the role to be created"
}

variable "path" {
  description = "The path for the role to be created"
  default     = null
}

# Trust policy variables

variable "trust_policy_source_policy_documents" {
  description = "A list of policy documents to use as the trust relationship for the role."
  type        = list(string)
}

# Permissions module variables

variable "state_bucket_arn" {
  type        = string
  description = "The ARN of the S3 bucket where the state files are stored."
}

variable "lock_table_arn" {
  type        = string
  description = "The ARN of the DynamoDB table used for state locking. If not provided, only S3 permissions will be generated."
  default     = null
}

variable "allow_full_bucket_list" {
  type        = bool
  description = "Whether to allow the role to list all objects in the state bucket rather than just those needed by workspace definitions. This can be useful for reducing the size of the generated policy."
  default     = false
}

variable "can_read" {
  description = "Backend configurations that can be read. This does not allow locking of state, useful when using terraform_remote_state data sources."
  type = list(object({
    key                     = string
    workspace_key_prefix    = optional(string, "env:")
    workspaces              = optional(list(string), ["*"])
    require_workspace_usage = optional(bool, false)
  }))
  default = []
}

variable "can_plan" {
  description = "Backend configurations that can be planned. State locking is allowed here for use in plans, however write access to the state bucket is prevented. WARNING: principals will be able to start apply runs using these permissions, but won't be able to write changes to state. Care should be take to prevent principals from making changes to resources as well as state."
  type = list(object({
    key                     = string
    workspace_key_prefix    = optional(string, "env:")
    workspaces              = optional(list(string), ["*"])
    require_workspace_usage = optional(bool, false)
  }))
  default = []
}

variable "can_apply" {
  description = "Backend configurations that can be applied. This allows locking of state and writing to the state bucket."
  type = list(object({
    key                     = string
    workspace_key_prefix    = optional(string, "env:")
    workspaces              = optional(list(string), ["*"])
    require_workspace_usage = optional(bool, false)
  }))
  default = []
}
