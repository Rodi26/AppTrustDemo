# Single-stage build that downloads JAR from Artifactory
FROM eclipse-temurin:21-jre

# Build arguments for Artifactory configuration
ARG ARTIFACTORY_URL=https://evidencetrial.jfrog.io
ARG REPOSITORY=commons-dev-maven-virtual
ARG GROUP_ID=com.example
ARG ARTIFACT_ID=quote-of-day-service
ARG VERSION=1.0.0-SNAPSHOT
ARG ARTIFACTORY_USERNAME=noam
ARG ARTIFACTORY_PASSWORD

# Set environment variables
ENV ARTIFACTORY_URL=$ARTIFACTORY_URL
ENV REPOSITORY=$REPOSITORY
ENV GROUP_ID=$GROUP_ID
ENV ARTIFACT_ID=$ARTIFACT_ID
ENV VERSION=$VERSION
ENV ARTIFACTORY_USERNAME=$ARTIFACTORY_USERNAME
ENV ARTIFACTORY_PASSWORD=$ARTIFACTORY_PASSWORD

# Create non-root user for security
RUN groupadd -r spring && \
    useradd -r -g spring spring

# Set working directory
WORKDIR /app

# Install wget for health check and curl for downloading
RUN apt-get update && \
    apt-get install -y wget curl && \
    rm -rf /var/lib/apt/lists/*

# Copy download script
COPY download-artifact.sh .
RUN chmod +x download-artifact.sh

# Switch to non-root user
USER spring

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/api/quotes/health || exit 1

# Run the application
ENTRYPOINT ["./download-artifact.sh"]
