output "ci_configs" {
  description = "map matching repo -> ci config (if exists)"
  value       = local.ci_configs
}

output "repositories" {
  description = "repositories matching filter"
  value       = local.repositories
}

output "user" {
  description = "authenticated user information"
  value       = local.github_user
}
