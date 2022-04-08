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
    # base OSS documents.
    "CODEOWNERS" = {
      path      = ".github/CODEOWNERS"
      languages = []
      skip_ci   = true
    }
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

    # IDE and/or linter configs.
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

    # issue templates.
    "ISSUE_TEMPLATE/bug_report.yml" = {
      path      = ".github/ISSUE_TEMPLATE/bug_report.yml"
      languages = []
      skip_ci   = true
    }
    "ISSUE_TEMPLATE/feature_request.yml" = {
      path      = ".github/ISSUE_TEMPLATE/feature_request.yml"
      languages = []
      skip_ci   = true
    }
    "ISSUE_TEMPLATE/config.yml" = {
      path      = ".github/ISSUE_TEMPLATE/config.yml"
      languages = []
      skip_ci   = true
    }
    "PULL_REQUEST_TEMPLATE.md" = {
      path      = ".github/PULL_REQUEST_TEMPLATE.md"
      languages = []
      skip_ci   = true
    }

    # scanning/dependency configs.
    "dependabot.yml" = {
      path      = ".github/dependabot.yml"
      languages = []
      skip_ci   = true
    }
  }
}
