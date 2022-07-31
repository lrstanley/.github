module "base" {
  source = "../modules/github-base"

  github_token = var.github-token

  filters = {
    isTemplate = false
    isFork     = false
    isEmpty    = false
    isPrivate  = false
  }
}

resource "github_repository_webhook" "discord" {
  for_each = { for repo in module.base.repositories : repo.name => repo }

  repository = each.value.name
  name       = "discord-webhook"

  configuration {
    url          = sensitive(var.discord-webhook-url)
    content_type = "json"
    insecure_ssl = false
  }

  active = true

  events = [
    "discussion",
    "discussion_comment",
    "issues",
    "issue_comment",
    "pull_request",
    "push",
    "release",
    "repository"
  ]
}
