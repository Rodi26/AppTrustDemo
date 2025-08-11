# Multi-stage build to create a clean runtime image
FROM eclipse-temurin:21-jre as runtime

# Create non-root user for security
RUN groupadd -r spring && \
    useradd -r -g spring spring

# Set working directory
WORKDIR /app

# Install wget for health check
RUN apt-get update && \
    apt-get install -y wget && \
    rm -rf /var/lib/apt/lists/*

# Copy the JAR file from the build context
COPY target/quote-of-day-service-*.jar app.jar

# Set proper ownership
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
