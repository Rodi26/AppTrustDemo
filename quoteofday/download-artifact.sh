#!/bin/bash

# Download JAR from Artifactory and run the application
set -e

# Default values (can be overridden by environment variables)
ARTIFACTORY_URL=${ARTIFACTORY_URL:-"https://evidencetrial.jfrog.io"}
REPOSITORY=${REPOSITORY:-"commons-dev-maven-virtual"}
GROUP_ID=${GROUP_ID:-"com.example"}
ARTIFACT_ID=${ARTIFACT_ID:-"quote-of-day-service"}
VERSION=${VERSION:-"1.0.0"}
USERNAME=${ARTIFACTORY_USERNAME:-"noam"}
PASSWORD=${ARTIFACTORY_PASSWORD:-""}

# Construct the download URL
DOWNLOAD_URL="${ARTIFACTORY_URL}/artifactory/${REPOSITORY}/${GROUP_ID//.//}/${ARTIFACT_ID}/${VERSION}/${ARTIFACT_ID}-${VERSION}.jar"

echo "🔍 Downloading artifact from Artifactory..."
echo "URL: ${DOWNLOAD_URL}"

# Download the JAR file
if [ -n "$PASSWORD" ]; then
    # Use authentication
    curl -u "${USERNAME}:${PASSWORD}" -L -o app.jar "${DOWNLOAD_URL}"
else
    # Try without authentication (for public repositories)
    curl -L -o app.jar "${DOWNLOAD_URL}"
fi

# Check if download was successful
if [ ! -f "app.jar" ]; then
    echo "❌ Failed to download artifact from Artifactory"
    echo "Please check:"
    echo "  - Artifactory URL: ${ARTIFACTORY_URL}"
    echo "  - Repository: ${REPOSITORY}"
    echo "  - Artifact coordinates: ${GROUP_ID}:${ARTIFACT_ID}:${VERSION}"
    echo "  - Authentication credentials"
    exit 1
fi

echo "✅ Successfully downloaded artifact: $(ls -lh app.jar)"

# Run the application
echo "🚀 Starting Spring Boot application..."
exec java -jar app.jar
