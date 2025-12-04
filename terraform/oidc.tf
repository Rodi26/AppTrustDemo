terraform {
  required_providers {
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
  url      = var.JF_URL
}

provider "platform" {
  url      = var.JF_URL
}

resource "jfrog_access_oidc_provider" "btcwallet_oidc" {
  name     = "btcwallet-gh"
  issuer   = "https://token.actions.githubusercontent.com"
  audiences = ["btcwallet-gh"]
  jwks_uri = "https://token.actions.githubusercontent.com/.well-known/jwks.json"
}

resource "jfrog_platform_oidc_identity_mapping" "btcwallet_mapping" {
  provider_name = jfrog_access_oidc_provider.btcwallet_oidc.name

  name = "github-actions-mapping" 

  claims = {
    # Claim key and expected value
    "actor" = var.github_owner,
    "repository" = "${var.github_owner}/${var.github_repository}"
  }

  # For example, mapping to a group or permission target
  user = [var.JF_USER]

  # Or permission targets can be specified here
  # permission_targets = ["readers", "writers"]

  # Optional: users, usernames, external groups, etc.
}
