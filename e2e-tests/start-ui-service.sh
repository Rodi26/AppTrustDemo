#!/bin/bash
set -e

echo "🚀 Starting BTCWallet UI service for testing..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if the UI image exists
if ! docker images | grep -q "btcwallet-ui"; then
    echo "📦 Building BTCWallet UI Docker image..."
    cd ../btcwallet-ui
    docker build -t btcwallet-ui:latest .
    cd ../e2e-tests
fi

# Check if port 8080 is already in use
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️ Port 8080 is already in use. Stopping existing container..."
    docker stop btcwallet-ui-test 2>/dev/null || true
    docker rm btcwallet-ui-test 2>/dev/null || true
fi

# Start the UI service
echo "🌐 Starting BTCWallet UI service on http://localhost:8080..."
docker run -d --name btcwallet-ui-test -p 8080:80 btcwallet-ui:latest

# Wait for service to be ready
echo "⏳ Waiting for UI service to be ready..."
for i in {1..30}; do
    if curl -f http://localhost:8080/ > /dev/null 2>&1; then
        echo "✅ BTCWallet UI service is ready at http://localhost:8080"
        echo "📋 Container ID: $(docker ps -q --filter name=btcwallet-ui-test)"
        echo "🛑 To stop the service: docker stop btcwallet-ui-test"
        exit 0
    fi
    sleep 1
done

echo "❌ UI service failed to start within 30 seconds"
exit 1
