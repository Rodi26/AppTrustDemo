#!/bin/bash
set -e

echo "🚀 Starting E2E test setup..."

# Install dependencies
echo "📦 Installing npm dependencies..."
npm ci --cache /root/.npm --prefer-offline

# Debug: Check current directory and files
echo "🔍 Current directory: $(pwd)"
echo "🔍 Directory contents before running tests:"
ls -la

# Run tests with explicit JSON reporter using cypress run directly
echo "🧪 Running Cypress tests with JSON reporter..."
npx cypress run --reporter json --reporter-options outputFile=cypress-results.json --spec 'cypress/e2e/**/*.cy.js'

# Debug: Check what files were created
echo "🔍 Directory contents after running tests:"
ls -la

# Check if the results file was created
if [ -f "cypress-results.json" ]; then
  echo "✅ Cypress results file found!"
  echo "📊 File size: $(wc -c < cypress-results.json) bytes"
  echo "📋 First 10 lines:"
  head -10 cypress-results.json
else
  echo "❌ Cypress results file not found"
  echo "🔍 Looking for any result files:"
  find . -name "*results*" -type f 2>/dev/null || echo "No result files found"
fi

echo "✅ E2E tests completed"
