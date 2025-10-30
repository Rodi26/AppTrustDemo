#!/bin/bash
set -e

echo "🚀 Starting E2E test setup..."

# Install dependencies
echo "📦 Installing npm dependencies..."
npm ci

# Check command line arguments
if [ "$1" = "e2e" ]; then
    echo "🧪 Running comprehensive E2E tests (btcwallet service + btcwallet UI)..."
    npx cypress run --spec 'cypress/e2e/end-to-end-btcwallet.cy.js'
elif [ "$1" = "all" ]; then
    echo "🧪 Running all tests (btcwallet service + E2E UI tests)..."
    npx cypress run --spec 'cypress/e2e/**/*.cy.js'
elif [ "$1" = "report" ]; then
    echo "🧪 Running all tests with report generation..."
    npx cypress run --spec 'cypress/e2e/**/*.cy.js'
    echo "📊 Generating test reports..."
    node generate-test-report.js
elif [ "$1" = "e2e-report" ]; then
    echo "🧪 Running E2E tests with report generation..."
    npx cypress run --spec 'cypress/e2e/end-to-end-btcwallet.cy.js'
    echo "📊 Generating test reports..."
    node generate-test-report.js
elif [ "$1" = "service-report" ]; then
    echo "🧪 Running service tests with report generation..."
    npx cypress run --spec 'cypress/e2e/btcwallet-service.cy.js'
    echo "📊 Generating test reports..."
    node generate-test-report.js
else
    echo "🧪 Running btcwallet service tests only..."
    npx cypress run --spec 'cypress/e2e/btcwallet-service.cy.js'
fi

echo "✅ E2E tests completed"
