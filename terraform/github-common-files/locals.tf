locals {
  module_name = basename(abspath(path.module))

  //  25 Go
  //  14 Makefile
  //  11 CSS
  //  10 Python
  //  10 JavaScript
  //   8 HTML
  //   6 Shell
  //   6 Dockerfile
  //   2 PHP
  //   2 C
  //   1 Vue
  //   1 Jsonnet
  file_map = {
    "CONTRIBUTING.md" = {
      path      = "CONTRIBUTING.md"
      languages = []
      skip_ci   = true
    }
    "CODE_OF_CONDUCT.md" = {
      path      = "CODE_OF_CONDUCT.md"
      languages = []
      skip_ci   = true
    }
    "SUPPORT.md" = {
      path      = "SUPPORT.md"
      languages = []
      skip_ci   = true
    }
    "SECURITY.md" = {
      path      = "SECURITY.md"
      languages = ["*"]
      skip_ci   = true
    }
    "LICENSE" = {
      path      = "LICENSE"
      languages = ["*"]
      skip_ci   = true
    }
    ".golangci.yml" = {
      path      = ".golangci.yml"
      languages = ["Go"]
      skip_ci   = false
    }
    ".editorconfig" = {
      path      = ".editorconfig"
      languages = ["*"]
      skip_ci   = true
    }
  }

  repositories_raw = jsondecode(data.graphql_query.repositories.query_response).data
  ci_configs_raw   = jsondecode(data.graphql_query.ci_config.query_response).data

  ci_configs = {
    for repo in local.ci_configs_raw.viewer.repositories.nodes : repo.name => (
      try(yamldecode(repo.object.text), null)
    )
  }

  github_user = {
    login       = local.repositories_raw.viewer.login
    name        = local.repositories_raw.viewer.name
    email       = local.repositories_raw.viewer.email
    avatar_url  = local.repositories_raw.viewer.avatarUrl
    website_url = local.repositories_raw.viewer.websiteUrl

    chat_url = format(
      "%s/chat", trimsuffix(local.repositories_raw.viewer.websiteUrl, "/")
    )
  }

  repositories = [
    for repo in local.repositories_raw.viewer.repositories.nodes : {
      name               = repo.name
      name_with_owner    = repo.nameWithOwner
      owner              = repo.owner.login
      url                = repo.url
      default_branch     = repo.defaultBranchRef.name
      config_repo        = repo.isUserConfigurationRepository
      homepage_url       = repo.homepageUrl
      pushed_at          = repo.pushedAt
      created_at         = repo.createdAt
      languages          = repo.languages.nodes[*].name
      has_issues_enabled = repo.hasIssuesEnabled
    }
    if !repo.isUserConfigurationRepository
    && repo.name == "liam.sh"
    && !repo.isArchived
    && !repo.isDisabled
    && !repo.isLocked
    && !repo.isMirror
    && !repo.isTemplate
    && !repo.isFork
    && !repo.isEmpty
    && !repo.isPrivate
  ]
}
