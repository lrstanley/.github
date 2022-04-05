data "graphql_query" "repositories" {
  query_variables = {}
  query           = file("${path.module}/graphql/get-repositories.graphql")
}

resource "github_repository_file" "standard_files" {
  # For each file map, check to see if the repository has a matching
  # language. If so, make a new object with all the necessary fields, and
  # then convert that to a id => object map to make it usable by for_each.
  for_each = {
    for obj in flatten([
      for repo in local.repositories : [
        for name, file in local.file_map : {
          key           = replace(join("_", [repo.name, name]), "/[^a-zA-Z0-9]+/", "_"),
          repo          = repo
          template_name = name
          file          = file
        }
        # file doesn't need any language.
        if length(file.languages) == 0
        # file needs any language.
        || contains(file.languages, "*")
        # file needs one of multiple specified language.
        || anytrue([for lang in file.languages : contains(repo.languages, lang)])
      ]
    ]) : obj.key => obj
  }

  repository          = each.value.repo.name
  branch              = each.value.repo.default_branch
  commit_message      = <<-EOT
  terraform: auto-applied "${each.value.file.path}"

  this file was auto-applied from the "${local.module_name}"
  module located here:
    - ${local.github_user.login}/.github/terraform/${local.module_name}/

  Signed-off-by: ${local.github_user.name} <${local.github_user.email}>
  EOT
  commit_author       = local.github_user.name
  commit_email        = local.github_user.email
  overwrite_on_create = true

  file = each.value.file.path
  content = templatefile("${path.module}/templates/${each.value.template_name}", {
    user = local.github_user
    repo = each.value.repo
  })
}
