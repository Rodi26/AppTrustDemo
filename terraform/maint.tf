provider "github" {
  #token      = var.github_token
  owner      = var.github_owner
}

# Variables
resource "github_actions_variable" "JF_URL" {
  variable_name       = "JF_URL"
  value      = var.JF_URL
  repository = var.github_repository
}

resource "github_actions_variable" "JF_USER" {
  variable_name       = "JF_USER"
  value      = var.JF_USER
  repository = var.github_repository
}

resource "github_actions_variable" "JF_PROJECT" {
  variable_name       = "JF_PROJECT"
  value      = var.JF_PROJECT
  repository = var.github_repository
}

resource "github_actions_variable" "JFROG_CLI_KEY_ALIAS" {
  variable_name       = "JFROG_CLI_KEY_ALIAS"
  value      = var.JFROG_CLI_KEY_ALIAS
  repository = var.github_repository
}

resource "github_actions_variable" "DOCKER_REGISTRY_PREFIX" {
  variable_name       = "DOCKER_REGISTRY_PREFIX"
  value      = var.DOCKER_REGISTRY_PREFIX
  repository = var.github_repository
}

resource "github_actions_variable" "PROJECT_DOCKER_DEV_REPO" {
  variable_name       = "PROJECT_DOCKER_DEV_REPO"
  value      = var.PROJECT_DOCKER_DEV_REPO
  repository = var.github_repository
}

resource "github_actions_variable" "PROJECT_DOCKER_QA_REPO" {
  variable_name       = "PROJECT_DOCKER_QA_REPO"
  value      = var.PROJECT_DOCKER_QA_REPO
  repository = var.github_repository
}

resource "github_actions_variable" "APPLICATION_NAME" {
  variable_name       = "APPLICATION_NAME"
  value      = var.APPLICATION_NAME
  repository = var.github_repository
}

resource "github_actions_variable" "TARGET_STAGE" {
  variable_name       = "TARGET_STAGE"
  value      = var.TARGET_STAGE
  repository = var.github_repository
}

resource "github_actions_variable" "PREPROD_STAGE" {
  variable_name       = "PREPROD_STAGE"
  value      = var.PREPROD_STAGE
  repository = var.github_repository
}

resource "github_actions_variable" "SOURCE_BUILD_NAME_BACKEND" {
  variable_name       = "SOURCE_BUILD_NAME_BACKEND"
  value      = var.SOURCE_BUILD_NAME_BACKEND
  repository = var.github_repository
}

resource "github_actions_variable" "SOURCE_BUILD_NAME_FRONTEND" {
  variable_name       = "SOURCE_BUILD_NAME_FRONTEND"
  value      = var.SOURCE_BUILD_NAME_FRONTEND
  repository = var.github_repository
}

resource "github_actions_variable" "SOURCE_BUILD_NAME_SERVICE" {
  variable_name       = "SOURCE_BUILD_NAME_SERVICE"
  value      = var.SOURCE_BUILD_NAME_SERVICE
  repository = var.github_repository
}

resource "github_actions_variable" "JIRA_URL" {
  variable_name       = "JIRA_URL"
  value      = var.JIRA_URL
  repository = var.github_repository
}

resource "github_actions_variable" "JIRA_USERNAME" {
  variable_name       = "JIRA_USERNAME"
  value      = var.JIRA_USERNAME
  repository = var.github_repository
}

resource "github_actions_variable" "JIRA_ID_REGEX" {
  variable_name       = "JIRA_ID_REGEX"
  value      = var.JIRA_ID_REGEX
  repository = var.github_repository
}

# Secrets
resource "github_actions_secret" "JFROG_CLI_SIGNING_KEY" {
  secret_name     = "JFROG_CLI_SIGNING_KEY"
  plaintext_value = var.JFROG_CLI_SIGNING_KEY
  repository      = var.github_repository
}

resource "github_actions_secret" "JF_ACCESS_TOKEN" {
  secret_name     = "JF_ACCESS_TOKEN"
  plaintext_value = var.JF_ACCESS_TOKEN
  repository      = var.github_repository
}

resource "github_actions_secret" "SONAR_TOKEN" {
  secret_name     = "SONAR_TOKEN"
  plaintext_value = var.SONAR_TOKEN
  repository      = var.github_repository
}

resource "github_actions_secret" "DEVELOCITY_ACCESS_KEY" {
  secret_name     = "DEVELOCITY_ACCESS_KEY"
  plaintext_value = var.DEVELOCITY_ACCESS_KEY
  repository      = var.github_repository
}

resource "github_actions_secret" "JIRA_API_TOKEN" {
  secret_name     = "JIRA_API_TOKEN"
  plaintext_value = var.JIRA_API_TOKEN
  repository      = var.github_repository
}

resource "github_actions_secret" "ARTIFACTORY_ACCESS_TOKEN" {
  secret_name     = "ARTIFACTORY_ACCESS_TOKEN"
  plaintext_value = var.ARTIFACTORY_ACCESS_TOKEN
  repository      = var.github_repository
}

resource "github_actions_secret" "EVIDENCE_PRIVATE_KEY" {
  secret_name     = "EVIDENCE_PRIVATE_KEY"
  plaintext_value = var.EVIDENCE_PRIVATE_KEY
  repository      = var.github_repository
}
