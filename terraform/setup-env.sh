#!/bin/bash
# Script pour exporter JFROG_ACCESS_TOKEN comme TF_VAR_JF_ACCESS_TOKEN
# Usage: source setup-env.sh

if [ -n "$JFROG_ACCESS_TOKEN" ]; then
  export TF_VAR_JF_ACCESS_TOKEN="$JFROG_ACCESS_TOKEN"
  echo "✓ TF_VAR_JF_ACCESS_TOKEN exporté depuis JFROG_ACCESS_TOKEN"
else
  echo "⚠ Attention: JFROG_ACCESS_TOKEN n'est pas défini"
fi



