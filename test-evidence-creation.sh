#!/bin/bash

# Test script for evidence creation
# Based on the workflow: .github/workflows/promote-application-version.yml

# Set variables (adjust these to match your environment)
APP_ID="btcwalletapp"
APP_VER="20"  # Use the version from your logs
TARGET_STAGE="QA"
STAGE="btcwallet-QA"  # QA maps to btcwallet-QA
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "Creating evidence for:"
echo "  Application: $APP_ID"
echo "  Version: $APP_VER"
echo "  Stage: $STAGE"
echo "  Timestamp: $TIMESTAMP"
echo ""

# Create predicate JSON
cat > gate-certify-predicate.json <<EOF
{
  "application_key": "$APP_ID",
  "application_name": "BTC Wallet App",
  "stage": "$STAGE",
  "gate": "exit",
  "status": "certified",
  "timestamp": "$TIMESTAMP"
}
EOF

echo "Predicate JSON content:"
cat gate-certify-predicate.json
echo ""

# Create markdown documentation
cat > gate-certify.md <<EOF
# Gate Certification Evidence - $STAGE Stage

- **Stage**: $STAGE
- **Gate Type**: exit
- **Status**: certified
- **Timestamp**: $TIMESTAMP
- **Application**: $APP_ID
- **Application Name**: BTC Wallet App
- **Version**: $APP_VER
EOF

echo "Markdown content:"
cat gate-certify.md
echo ""

# Check if signing key is set
if [ -z "$JFROG_CLI_SIGNING_KEY" ]; then
    echo "⚠️  Warning: JFROG_CLI_SIGNING_KEY environment variable is not set"
    echo "   You can set it with: export JFROG_CLI_SIGNING_KEY='your-key-here'"
    echo "   Or use --key flag in the command below"
    echo ""
fi

# Create evidence using CLI
echo "Running evidence creation command..."
# Note: The CLI will use JFROG_CLI_SIGNING_KEY env var if set, or you can add --key flag
jf evd create \
    --application-key "$APP_ID" \
    --application-version "$APP_VER" \
    --predicate gate-certify-predicate.json \
    --predicate-type https://jfrog.com/evidence/apptrust/gate-certify/v1 \
    --markdown gate-certify.md \
    --provider-id apptrust

if [ $? -eq 0 ]; then
    echo "✅ Evidence created successfully!"
else
    echo "❌ Failed to create evidence"
    exit 1
fi