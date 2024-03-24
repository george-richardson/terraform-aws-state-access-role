variable "trust_policy_source_policy_documents" {
  type    = list(string)
  default = []
}

variable "trust_policy_override_policy_documents" {
  type    = list(string)
  default = []
}

variable "trusted_aws_principals" {
  type = list(object({
    principals                  = list(string)
    principal_condition_filters = optional(list(string), [])
    org_paths_condition_filters = optional(list(string), [])
    sid                         = optional(string, null)
  }))
  default = []
}

variable "trusted_github_oidc_principals" {
  type = list(object({
    oidc_provider_arn = string # TODO could be hardcoded?
    sub_filters       = list(string)
    aud               = optional(string, "sts.amazonaws.com")
    sid               = optional(string, null)
  }))
  default = []
}
