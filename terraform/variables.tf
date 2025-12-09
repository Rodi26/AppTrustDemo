

variable "github_owner" {
  description = "GitHub repository owner or organization."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name."
  type        = string
}

variable "JF_URL" {
  description = "JFrog URL."
  type        = string
}

variable "JF_USER" {
  description = "JFrog user."
  type        = string
}

variable "JF_PROJECT" {
  description = "JFrog project."
  type        = string
}

variable "JFROG_CLI_KEY_ALIAS" {
  description = "JFrog CLI key alias."
  type        = string
}

variable "DOCKER_REGISTRY_PREFIX" {
  description = "Docker registry prefix."
  type        = string
}

variable "PROJECT_DOCKER_DEV_REPO" {
  description = "Project Docker dev repository."
  type        = string
}

variable "PROJECT_DOCKER_QA_REPO" {
  description = "Project Docker QA repository."
  type        = string
}

variable "APPLICATION_NAME" {
  description = "Application name."
  type        = string
}

variable "TARGET_STAGE" {
  description = "Deployment target stage."
  type        = string
}

variable "PREPROD_STAGE" {
  description = "Preprod deployment stage."
  type        = string
}

variable "SOURCE_BUILD_NAME_BACKEND" {
  description = "Source build name for backend."
  type        = string
}

variable "SOURCE_BUILD_NAME_FRONTEND" {
  description = "Source build name for frontend."
  type        = string
}

variable "SOURCE_BUILD_NAME_SERVICE" {
  description = "Source build name for service."
  type        = string
}

variable "JIRA_URL" {
  description = "JIRA instance URL."
  type        = string
}

variable "JIRA_USERNAME" {
  description = "JIRA username."
  type        = string
}

variable "JIRA_ID_REGEX" {
  description = "Regex for extracting JIRA IDs."
  type        = string
}

variable "JFROG_MVN_REPO_VIRTUAL" {
  description = "JFrog Maven virtual repository."
  type        = string
}

variable "JFROG_MVN_REPO_SNAPSHOTS" {
  description = "JFrog Maven snapshots repository."
  type        = string
}

variable "JFROG_MVN_REPO_RELEASES" {
  description = "JFrog Maven releases repository."
  type        = string
}

variable "JFROG_CLI_SIGNING_KEY" {
  description = "JFrog CLI signing key (secret). Can be set via TF_VAR_JFROG_CLI_SIGNING_KEY env var or read from file."
  type        = string
  sensitive   = true
  default     = null
}

variable "JF_ACCESS_TOKEN" {
  description = "JFrog access token (secret). Can be set via TF_VAR_JF_ACCESS_TOKEN or JFROG_ACCESS_TOKEN env var."
  type        = string
  sensitive   = true
  default     = null
}

locals {
  jfrog_access_token = var.JF_ACCESS_TOKEN != null ? var.JF_ACCESS_TOKEN : try(env("JFROG_ACCESS_TOKEN"), "")
  jfrog_cli_signing_key = var.JFROG_CLI_SIGNING_KEY != null ? var.JFROG_CLI_SIGNING_KEY : try(file("${path.module}/signing_key_rsa.pem"), "")
}

variable "SONAR_TOKEN" {
  description = "Sonar token (secret)."
  type        = string
  sensitive   = true
}

variable "DEVELOCITY_ACCESS_KEY" {
  description = "Develocity access key (secret)."
  type        = string
  sensitive   = true
}

variable "JIRA_API_TOKEN" {
  description = "JIRA API token (secret)."
  type        = string
  sensitive   = true
}

variable "ARTIFACTORY_ACCESS_TOKEN" {
  description = "Artifactory access token (secret)."
  type        = string
  sensitive   = true
}

variable "EVIDENCE_PRIVATE_KEY" {
  description = "Evidence private key (secret)."
  type        = string
  sensitive   = true
}
