# Multi-stage build to create a clean runtime image
FROM eclipse-temurin:21-jre AS runtime

# Create non-root user and set up environment in one layer
RUN groupadd -r spring && \
    useradd -r -g spring spring && \
    mkdir -p /app && \
    chown spring:spring /app

# Set working directory
WORKDIR /app

# Install wget for health check in one layer
RUN apt-get update && \
    apt-get install -y wget && \
    rm -rf /var/lib/apt/lists/*

# Copy the JAR file and set ownership in one layer
COPY target/quote-of-day-service-*.jar app.jar
RUN chown spring:spring /app/app.jar

# Switch to non-root user
USER spring

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/api/quotes/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
