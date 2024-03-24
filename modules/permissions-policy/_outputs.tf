output "json" {
  description = "The JSON representation of the permissions policy."
  value       = data.aws_iam_policy_document.permissions.json
}
