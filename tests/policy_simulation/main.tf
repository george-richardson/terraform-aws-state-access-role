variable "action_names" {
  type = list(string)
}

variable "policy_source_arn" {
  type = string
}

variable "resource_arns" {
  type = list(string)
}

variable "contexts" {
  type = list(object({
    key    = string
    type   = string
    values = list(string)
  }))
  default = []
}

data "aws_iam_principal_policy_simulation" "test" {
  action_names      = var.action_names
  policy_source_arn = var.policy_source_arn
  resource_arns     = var.resource_arns

  dynamic "context" {
    for_each = var.contexts
    content {
      key    = context.value.key
      type   = context.value.type
      values = context.value.values
    }
  }
}

output "test_results" {
  value = data.aws_iam_principal_policy_simulation.test
}
