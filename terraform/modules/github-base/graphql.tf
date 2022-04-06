data "graphql_query" "repositories" {
  query_variables = {}
  query           = file("${path.module}/graphql/get-repositories.graphql")
}

data "graphql_query" "ci_config" {
  query_variables = {}
  query           = file("${path.module}/graphql/get-ci-config.graphql")
}
