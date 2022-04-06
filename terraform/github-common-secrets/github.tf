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

resource "github_actions_secret" "common_secrets" {
  for_each = {
    for obj in flatten([
      for name, secret in local.secrets : [
        for repo in module.base.repositories : {
          key    = replace(join("_", [repo.name, name]), "/[^a-zA-Z0-9]+/", "_")
          repo   = repo
          name   = name
          secret = secret
        }
      ]
    ]) : obj.key => obj
  }

  repository      = each.value.repo.name
  secret_name     = each.value.name
  plaintext_value = sensitive(each.value.secret)
}
