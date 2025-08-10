#!/bin/bash

# Download JAR from Artifactory and run the application
set -e

# Default values (can be overridden by environment variables)
ARTIFACTORY_URL=${ARTIFACTORY_URL:-"https://evidencetrial.jfrog.io"}
REPOSITORY=${REPOSITORY:-"commons-dev-maven-virtual"}
GROUP_ID=${GROUP_ID:-"com.example"}
ARTIFACT_ID=${ARTIFACT_ID:-"quote-of-day-service"}
VERSION=${VERSION:-"1.0.0-SNAPSHOT"}
USERNAME=${ARTIFACTORY_USERNAME:-"noam"}
PASSWORD=${ARTIFACTORY_PASSWORD:-""}

# Construct the download URL
DOWNLOAD_URL="${ARTIFACTORY_URL}/artifactory/${REPOSITORY}/${GROUP_ID//.//}/${ARTIFACT_ID}/${VERSION}/${ARTIFACT_ID}-${VERSION}.jar"

echo "🔍 Downloading artifact from Artifactory..."
echo "URL: ${DOWNLOAD_URL}"
echo "Repository: ${REPOSITORY}"
echo "Group ID: ${GROUP_ID}"
echo "Artifact ID: ${ARTIFACT_ID}"
echo "Version: ${VERSION}"

# Download the JAR file with verbose output
if [ -n "$PASSWORD" ]; then
    # Use authentication
    echo "🔐 Using authentication for download..."
    curl -v -u "${USERNAME}:${PASSWORD}" -L -o app.jar "${DOWNLOAD_URL}"
else
    # Try without authentication (for public repositories)
    echo "🌐 Attempting download without authentication..."
    curl -v -L -o app.jar "${DOWNLOAD_URL}"
fi

# Check if download was successful
if [ ! -f "app.jar" ]; then
    echo "❌ Failed to download artifact from Artifactory"
    echo "Please check:"
    echo "  - Artifactory URL: ${ARTIFACTORY_URL}"
    echo "  - Repository: ${REPOSITORY}"
    echo "  - Artifact coordinates: ${GROUP_ID}:${ARTIFACT_ID}:${VERSION}"
    echo "  - Authentication credentials"
    echo "  - Full URL: ${DOWNLOAD_URL}"
    exit 1
fi

# Check file size
FILE_SIZE=$(stat -c%s app.jar 2>/dev/null || stat -f%z app.jar 2>/dev/null || echo "unknown")
echo "✅ Successfully downloaded artifact: $(ls -lh app.jar) (${FILE_SIZE} bytes)"

# Validate JAR file
if [ "$FILE_SIZE" -lt 1000 ]; then
    echo "⚠️ Warning: JAR file seems too small (${FILE_SIZE} bytes). It might be an error page."
    echo "📋 File content preview:"
    head -20 app.jar
    exit 1
fi

# Run the application
echo "🚀 Starting Spring Boot application..."
exec java -jar app.jar
