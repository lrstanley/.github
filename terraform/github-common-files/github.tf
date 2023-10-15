module "base" {
  source = "../modules/github-base"

  github_token = var.github-token

  filters = {
    isTemplate = false
    isFork     = false
    isEmpty    = false
    isPrivate  = false
  }

  exclude_names = [".github"]
}

resource "github_repository_file" "standard_files" {
  # for each file map, check to see if the repository has a matching
  # language. if so, make a new object with all the necessary fields, and
  # then convert that to a id => object map to make it usable by for_each.
  for_each = {
    for obj in flatten([
      for repo in module.base.repositories : [
        for name, file in local.file_map : {
          key           = replace(join("_", [repo.name, name]), "/[^a-zA-Z0-9]+/", "_"),
          repo          = repo
          template_name = name
          file          = file
        }
        # file doesn't need any language.
        if(
          length(file.languages) == 0
          # file needs any language.
          || contains(file.languages, "*")
          # file needs one of multiple specified language.
          || anytrue([for lang in file.languages : contains(repo.languages, lang)])
          ) && (
          # check to see if the file is in the list of excluded files
          # configured inside of the repository.
          !try(anytrue([
            for excl in module.base.ci_configs[repo.name].common_exclude :
            length(regexall(excl, file.path)) > 0
          ]), false)
        )
      ]
    ]) : obj.key => obj
  }

  repository          = each.value.repo.name
  branch              = each.value.repo.default_branch
  commit_message      = <<-EOT
  chore(terraform): auto-applied "${each.value.file.path}" ${each.value.file.skip_ci ? "[skip ci]" : ""}

  this file was auto-applied from the "${local.module_name}" module
  located here:
    - https://github.com/${module.base.user.login}/.github/tree/master/terraform/${local.module_name}

  instructions on how to tell Terraform to exclude this file:
    - https://github.com/${module.base.user.login}/.github/blob/master/example.ci-config.yml

  Signed-off-by: ${module.base.user.name} <${module.base.user.email}>
  EOT
  commit_author       = module.base.user.name
  commit_email        = module.base.user.email
  overwrite_on_create = true

  file = each.value.file.path
  content = templatefile("${path.module}/templates/${each.value.template_name}", {
    user = module.base.user
    repo = each.value.repo
  })

  lifecycle {
    ignore_changes = [
      commit_message,
      commit_author,
      commit_email,
    ]
  }
}
