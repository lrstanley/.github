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
    }
    "CODE_OF_CONDUCT.md" = {
      path      = "CODE_OF_CONDUCT.md"
      languages = []
    }
    "SUPPORT.md" = {
      path      = "SUPPORT.md"
      languages = []
    }
    "SECURITY.md" = {
      path      = "SECURITY.md"
      languages = ["*"]
    }
    "LICENSE" = {
      path      = "LICENSE"
      languages = ["*"]
    }
    ".golangci.yml" = {
      path      = ".golangci.yml"
      languages = ["Go"]
    }
    ".editorconfig" = {
      path      = ".editorconfig"
      languages = ["*"]
    }
  }

  repositories_raw = jsondecode(data.graphql_query.repositories.query_response).data
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
