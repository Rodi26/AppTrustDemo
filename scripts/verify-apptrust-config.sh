#!/bin/bash
# Script de vérification des paramètres AppTrust
# Vérifie : application, stages, versions, policies, cohérence des noms
#
# Usage:
#   export JF_URL="https://your-instance.jfrog.io"
#   export JF_ACCESS_TOKEN="your-admin-token"
#   ./scripts/verify-apptrust-config.sh [APP_ID] [PROJECT_KEY]
#
# Ou avec des valeurs par défaut (btcwalletapp, btcwallet):
#   ./scripts/verify-apptrust-config.sh

set -euo pipefail

# === Configuration ===
APP_ID="${1:-${APPLICATION_KEY:-${APPLICATION_NAME:-btcwalletapp}}}"
PROJECT_KEY="${2:-${JF_PROJECT:-btcwallet}}"
JF_URL="${JF_URL:-}"
JF_ACCESS_TOKEN="${JF_ACCESS_TOKEN:-}"

# Valeurs attendues (référence du projet)
EXPECTED_STAGES_ACCESS=("DEV" "btcwallet-QA" "btcwallet-PreProd" "PROD")
EXPECTED_GATE_STAGES=("btcwallet-QA" "btcwallet-PreProd")
TARGET_STAGE_QA="QA"
TARGET_STAGE_PREPROD="PreProd"

# === Vérifications préalables ===
check_requirements() {
  local missing=()
  [ -z "$JF_URL" ] && missing+=("JF_URL")
  [ -z "$JF_ACCESS_TOKEN" ] && missing+=("JF_ACCESS_TOKEN")
  if [ ${#missing[@]} -gt 0 ]; then
    echo "❌ Variables manquantes: ${missing[*]}"
    echo ""
    echo "Usage:"
    echo "  export JF_URL=\"https://your-instance.jfrog.io\""
    echo "  export JF_ACCESS_TOKEN=\"your-admin-access-token\""
    echo "  ./scripts/verify-apptrust-config.sh [APP_ID] [PROJECT_KEY]"
    echo ""
    echo "Exemple:"
    echo "  export JF_URL=\"https://trainingdayapptrustb.jfrog.io\""
    echo "  export JF_ACCESS_TOKEN=\"\$(cat ~/.jfrog-token)\""
    echo "  ./scripts/verify-apptrust-config.sh btcwalletapp btcwallet"
    exit 1
  fi

  if ! command -v jq &>/dev/null; then
    echo "❌ jq est requis. Installez-le avec: brew install jq"
    exit 1
  fi

  if ! command -v curl &>/dev/null; then
    echo "❌ curl est requis."
    exit 1
  fi
}

# Trim trailing slash
JF_URL="${JF_URL%/}"

# === Appels API ===
api_get() {
  local url="$1"
  local resp
  resp=$(curl -s -w "\n%{http_code}" -X GET \
    -H "Authorization: Bearer $JF_ACCESS_TOKEN" \
    "$url" 2>/dev/null || true)
  if [ -z "$resp" ]; then
    echo "{\"error\":\"empty_response\"}" 
    return 1
  fi
  local status="${resp##*$'\n'}"
  local body="${resp%$'\n'*}"
  if [ "$status" != "200" ] && [ "$status" != "201" ]; then
    echo "{\"error\":\"HTTP $status\"}"
    return 1
  fi
  echo "$body"
}

# === Vérifications ===
print_header() {
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "  $1"
  echo "═══════════════════════════════════════════════════════════════"
}

check_apptrust_application() {
  print_header "1. Application AppTrust"
  local url="$JF_URL/apptrust/api/v1/applications/$APP_ID"
  echo "GET $url"
  local resp
  resp=$(api_get "$url" || true)
  if echo "$resp" | jq -e '.error' &>/dev/null; then
    echo "❌ Application non trouvée ou inaccessible"
    echo "$resp" | jq -r '.body // .error // .' 2>/dev/null || echo "$resp"
    return 1
  fi
  echo "✅ Application trouvée:"
  echo "$resp" | jq -r '
    "  - application_key: \(.application_key // .key // "N/A")
  - application_name: \(.application_name // .name // "N/A")
  - project_key: \(.project_key // "N/A")
  - description: \(.description // "N/A")"
  ' 2>/dev/null || echo "$resp" | jq .
  return 0
}

check_apptrust_versions() {
  print_header "2. Versions et stage actuel"
  local url="$JF_URL/apptrust/api/v1/applications/$APP_ID/versions?order_by=created&limit=5"
  echo "GET $url"
  local resp
  resp=$(api_get "$url" || true)
  if echo "$resp" | jq -e '.error' &>/dev/null; then
    echo "❌ Impossible de récupérer les versions"
    echo "$resp" | jq -r '.body // .error // .' 2>/dev/null || echo "$resp"
    return 1
  fi
  local count
  count=$(echo "$resp" | jq '.versions | length' 2>/dev/null || echo "0")
  if [ "$count" = "0" ] || [ "$count" = "null" ]; then
    echo "⚠️  Aucune version trouvée"
    return 0
  fi
  echo "✅ Dernières versions:"
  echo "$resp" | jq -r '.versions[]? | "  - version \(.version): current_stage=\(.current_stage // .stage // .stages[0] // "N/A")"' 2>/dev/null
  local latest_stage
  latest_stage=$(echo "$resp" | jq -r '.versions[0].current_stage // .versions[0].stage // .versions[0].stages[0] // "N/A"' 2>/dev/null)
  echo ""
  echo "  → Stage de la dernière version: \"$latest_stage\""
  if [ "$latest_stage" != "DEV" ] && [ "$latest_stage" != "dev" ]; then
    echo "  ⚠️  Si la promotion DEV→QA échoue avec 'Must have been through Dev Stage',"
    echo "     vérifiez que le lifecycle AppTrust utilise bien 'DEV' (et non btcwallet-dev)."
  fi
  return 0
}

check_access_stages() {
  print_header "3. Stages du projet (Access API)"
  # Essayer plusieurs endpoints possibles
  local url="$JF_URL/access/api/v2/stages/?project_key=$PROJECT_KEY"
  echo "GET $url"
  local resp
  resp=$(api_get "$url" 2>/dev/null || true)
  if echo "$resp" | jq -e '.error' &>/dev/null; then
    url="$JF_URL/access/api/v2/stages/"
    echo "Tentative alternative: GET $url"
    resp=$(api_get "$url" 2>/dev/null || true)
  fi
  if echo "$resp" | jq -e '.error' &>/dev/null; then
    echo "⚠️  Impossible de lister les stages (endpoint peut varier)"
    echo "   Stages attendus: ${EXPECTED_STAGES_ACCESS[*]}"
    return 0
  fi
  echo "✅ Stages configurés:"
  local stages
  stages=$(echo "$resp" | jq -r '.[].name // .stages[].name // .name // empty' 2>/dev/null)
  if [ -z "$stages" ]; then
    stages=$(echo "$resp" | jq -r 'if type == "array" then .[].name else .name end' 2>/dev/null)
  fi
  if [ -n "$stages" ]; then
    echo "$stages" | while read -r s; do echo "  - $s"; done
  else
    echo "$resp" | jq .
  fi
  return 0
}

check_unifiedpolicy_rules() {
  print_header "4. Règles Gate Certification (Unified Policy)"
  local url="$JF_URL/unifiedpolicy/api/v1/rules"
  echo "GET $url"
  local resp
  resp=$(api_get "$url" 2>/dev/null || true)
  if echo "$resp" | jq -e '.error' &>/dev/null; then
    echo "⚠️  Impossible de lister les règles"
    return 0
  fi
  echo "Règles gate-certify (template 1004 ou predicateType gate-certify):"
  local matched
  matched=$(echo "$resp" | jq -r '
    (if type == "array" then . else (.items // .rules // .data // .) end) as $rules |
    ($rules | if type == "array" then . else [.] end) |
    .[] |
    select(.template_id == "1004" or (.parameters // [] | any(.name == "predicateType" and .value == "https://jfrog.com/evidence/apptrust/gate-certify/v1"))) |
    "  - \(.name): stage=\(.parameters // [] | map(select(.name == "stage")) | .[0].value // "N/A")"
  ' 2>/dev/null)
  if [ -n "$matched" ]; then
    echo "$matched"
  else
    echo "  (aucune règle gate-certify trouvée)"
    if [ "${SHOW_RAW:-0}" = "1" ]; then
      echo ""
      echo "Réponse brute (structure):"
      echo "$resp" | jq '.' 2>/dev/null | head -80 || echo "$resp" | head -c 800
    else
      echo "  Astuce: export SHOW_RAW=1 pour afficher la structure de la réponse"
    fi
  fi
  return 0
}

check_consistency() {
  print_header "5. Cohérence des noms (workflow vs config)"
  echo "Référence du projet:"
  echo "  - APPLICATION_KEY / APP_ID: $APP_ID"
  echo "  - TARGET_STAGE (QA): doit correspondre au stage du lifecycle pour la promotion"
  echo "  - Gate evidence: stage dans le predicate doit être 'btcwallet-QA' ou 'btcwallet-PreProd'"
  echo ""
  echo "Mapping workflow (promote-application-version.yml):"
  echo "  TARGET_STAGE=QA    → evidence stage='btcwallet-QA'"
  echo "  TARGET_STAGE=PreProd → evidence stage='btcwallet-PreProd'"
  echo ""
  echo "Erreur fréquente 'Must have been through Dev Stage':"
  echo "  → Le lifecycle AppTrust exige que la version soit passée par le stage 'DEV'."
  echo "  → Vérifiez que:"
  echo "    1. La version est bien en stage DEV avant promotion (cf. section 2)"
  echo "    2. Le lifecycle de l'application inclut 'DEV' comme premier stage"
  echo "    3. L'evidence gate-certify pour DEV (exit) a été créée avant la promotion"
  return 0
}

# === Main ===
main() {
  echo "Vérification AppTrust - $APP_ID (projet: $PROJECT_KEY)"
  check_requirements
  check_apptrust_application
  check_apptrust_versions
  check_access_stages
  check_unifiedpolicy_rules
  check_consistency
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "  Vérification terminée"
  echo "═══════════════════════════════════════════════════════════════"
}

main "$@"
