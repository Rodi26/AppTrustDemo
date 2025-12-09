terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    artifactory = {
      source  = "jfrog/artifactory"
      version = "12.11.0"
    }
    platform = {
      source  = "jfrog/platform"
      version = "2.2.6"
    }
  }
}

provider "artifactory" {
  url         = var.JF_URL
  access_token = var.JF_ACCESS_TOKEN
}

provider "platform" {
  url         = var.JF_URL
  access_token = var.JF_ACCESS_TOKEN
}

resource "platform_oidc_configuration" "btcwallet_oidc" {
  provider      = platform
  name          = "btcwallet-gh"
  issuer_url    = "https://token.actions.githubusercontent.com"
  audience      = "btcwallet-gh"
  provider_type = "GitHub"
  # organization is optional but recommended for GitHub
  organization  = var.github_owner
  description   = "OIDC configuration for GitHub Actions authentication"
}

resource "platform_oidc_identity_mapping" "btcwallet_mapping" {
  provider      = platform
  provider_name = platform_oidc_configuration.btcwallet_oidc.name
  name          = "github-actions-mapping"
  priority      = 1

  claims_json = jsonencode({
    actor      = var.github_owner
    repository = "${var.github_owner}/${var.github_repository}"
  })

  token_spec = {
    username = var.JF_USER
    scope    = "applied-permissions/admin"
  }
}
