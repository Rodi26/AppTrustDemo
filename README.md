# Quotopia - JFrog Evidence Integration Demo

A comprehensive demonstration of JFrog Evidence solution integration with CI/CD workflows, showcasing evidence creation from multiple sources and automated promotion flows from development to production.

## 🎯 Overview

This project demonstrates how to integrate JFrog Evidence with GitHub Actions CI/CD pipelines to create a complete software supply chain security and compliance solution. It showcases evidence collection from various tools and automated promotion through different environments with gating controls.

### Key Features

- **Multi-technology Stack**: Java+Maven, Python, and Static HTML/JS applications
- **GitHub Actions CI/CD**: Automated builds, tests, and deployments
- **Evidence Collection**: JUnit tests, SonarQube analysis, Grype security scans, Cypress E2E tests, and JIRA issue tracking
- **Automated Promotion Flow**: DEV → QA → PROD with evidence validation
- **AppTrust Gating**: Production releases require all evidence gates to pass
- **Release Bundle Management**: Application versioning with complete artifact traceability

## 🏗️ Architecture

The Quotopia application consists of three microservices, each demonstrating different technology stacks:

### Services Overview

| Service | Technology | Port | Purpose | Docker Image |
|---------|------------|------|---------|--------------|
| **quoteofday** | Java + Maven + Spring Boot | 8001 | REST API for daily inspirational quotes | `quotopia-dev-docker/quoteofday` |
| **ai-translate** | Python + FastAPI | 8002 | AI translation service using Helsinki-NLP model | `quotopia-dev-docker/ai-translate` |
| **quotopia-ui** | Static Website (HTML/CSS/JS) | 80 | Frontend for quote display and interaction | `quotopia-dev-docker/quotopia-ui` |

### Service Details

#### Quote of Day Service
- **Framework**: Spring Boot 3.2.0 with Java 21
- **Build Tool**: Maven
- **Testing**: JUnit 5 with comprehensive test coverage
- **Quality Gates**: SonarQube analysis and Gradle Develocity attestation
- **API Endpoints**: 
  - `GET /api/quotes/today` - Today's quote
  - `GET /api/quotes/date/{date}` - Quote for specific date
  - `GET /api/quotes/health` - Health check

#### AI Translation Service
- **Framework**: FastAPI with Python 3.11
- **AI Model**: Helsinki-NLP/opus-mt-en-fr for English to French translation
- **Security**: Grype vulnerability scanning
- **API Endpoints**:
  - `POST /translate` - Single text translation
  - `POST /translate/batch` - Batch translation
  - `GET /health` - Service health check

#### Quotopia UI
- **Technology**: Pure HTML/CSS/JavaScript
- **Features**: Responsive design, interactive quote cards, date selection
- **Integration**: Consumes quoteofday API for dynamic content
- **Testing**: Cypress E2E tests for full user journey validation

## 🔄 CI/CD Workflows

The project implements a comprehensive CI/CD pipeline with evidence collection at every stage.

### Individual Service Builds

#### A. Quote of Day Service CI
**File**: `.github/workflows/quoteofday-ci.yml`

**Triggers**: Push to `quoteofday/**` or manual dispatch

**Process**:
1. **Build Phase**:
   - Setup JDK 21 with Maven caching
   - Build and deploy artifacts to Artifactory
   - Run JUnit tests with coverage reporting
   
2. **Quality Gates**:
   - SonarQube code quality analysis
   - Gradle Develocity build attestation
   
3. **Containerization**:
   - Multi-architecture Docker build (amd64, arm64)
   - Push to JFrog Artifactory Docker registry
   
4. **Evidence Creation**:
   - JUnit test results evidence
   - SonarQube integration evidence
   - JIRA issue tracking evidence (from commit messages)

#### B. AI Translate Service CI
**File**: `.github/workflows/ai-translate-ci.yml`

**Triggers**: Push to `translate/**` or manual dispatch

**Process**:
1. **Testing Phase**:
   - Python 3.11 setup with pip caching
   - Run pytest test suite
   
2. **Containerization**:
   - Single-architecture Docker build (amd64)
   - Registry caching for build optimization
   
3. **Security Scanning**:
   - Grype vulnerability scan
   - Evidence creation from scan results
   
4. **Evidence Creation**:
   - Security scan evidence
   - JIRA issue tracking evidence

#### C. Quotopia UI Service CI
**File**: `.github/workflows/quotopia-ui-ci.yml`

**Triggers**: Push to `quotopia-ui/**` or manual dispatch

**Process**:
1. **Containerization**:
   - Multi-architecture Docker build (amd64, arm64)
   - Static website serving with Nginx
   
2. **Validation**:
   - Docker image testing
   - Web server functionality verification
   
3. **Evidence Creation**:
   - JIRA issue tracking evidence

### Application Version Management

#### D. Create Application Version
**File**: `.github/workflows/create-application-version.yml`

**Purpose**: Combine all three services into a single application version

**Process**:
1. **Version Discovery**:
   - Get latest build numbers for all services
   - Retrieve current application version
   
2. **Version Creation**:
   - Create new application version with all builds
   - Automatically promote to DEV stage
   
3. **Output**: New application version in AppTrust with complete build traceability

#### E. Promote to QA
**File**: `.github/workflows/promote-application-version.yml`

**Purpose**: Promote application to QA environment and run comprehensive E2E tests

**Process**:
1. **Promotion**:
   - Get latest application version
   - Promote to QA stage in AppTrust
   
2. **Environment Setup**:
   - Extract Docker image versions from application
   - Pull images from QA repository
   - Start Docker services for testing
   
3. **E2E Testing**:
   - Run Cypress end-to-end tests
   - Generate comprehensive test reports
   - Create evidence from test results
   
4. **Evidence**: Cypress E2E test reports attached to release bundle

#### F. Release to PROD
**File**: `.github/workflows/release-application-version.yml`

**Purpose**: Release application to production after AppTrust gating validation

**Process**:
1. **Release Validation**:
   - Get latest application version
   - Release to PROD (triggers AppTrust validation)
   - All evidence gates must pass
   
2. **Deployment**:
   - Update ArgoCD deployment manifests
   - Commit and push updated configurations
   - Trigger production deployment

**Gating**: AppTrust validates all evidence before allowing release

## 📋 Evidence Types

The system creates evidence from multiple sources throughout the CI/CD pipeline:

| Evidence Type | Source | Predicate Type | Provider | Purpose |
|---------------|--------|----------------|----------|---------|
| **JUnit Test Results** | quoteofday tests | `https://jfrog.com/evidence/test-results/v1` | junit | Unit test coverage and results |
| **SonarQube Analysis** | Code quality scan | Integration | sonar | Code quality metrics and issues |
| **Grype Security Scan** | ai-translate container | `https://anchore.com/evidence/grype/v1` | anchore | Vulnerability assessment |
| **Cypress E2E Tests** | End-to-end testing | `https://cypress.io/evidence/e2e/v1` | cypress | Integration and UI testing |
| **JIRA Issue Tracking** | Commit messages | `http://atlassian.com/jira/issues/v1` | jira | Issue tracking and compliance |

## 📁 Repository Structure

```
evidence-integration/
├── .github/workflows/          # GitHub Actions CI/CD workflows
│   ├── quoteofday-ci.yml       # Java service build pipeline
│   ├── ai-translate-ci.yml     # Python service build pipeline
│   ├── quotopia-ui-ci.yml      # UI service build pipeline
│   ├── create-application-version.yml    # Application versioning
│   ├── promote-application-version.yml   # QA promotion
│   ├── release-application-version.yml   # PROD release
│   ├── end2end-tests.yml       # E2E testing workflow
│   └── create-jira-evidence.yml # JIRA evidence helper
├── quoteofday/                 # Java + Maven service
│   ├── src/                    # Source code
│   ├── target/                 # Build artifacts
│   ├── Dockerfile              # Container definition
│   └── README.md               # Service documentation
├── translate/                  # Python AI translation service
│   ├── app.py                  # FastAPI application
│   ├── translation_service.py  # Translation logic
│   ├── tests/                  # Test suite
│   ├── Dockerfile              # Container definition
│   └── README.md               # Service documentation
├── quotopia-ui/                # Static website
│   ├── index.html              # Main page
│   ├── styles.css              # Styling
│   ├── script.js               # JavaScript logic
│   ├── Dockerfile              # Container definition
│   └── README.md               # Service documentation
├── e2e-tests/                  # Cypress E2E tests
│   ├── cypress/                # Test specifications
│   ├── package.json            # Dependencies
│   └── README.md               # Testing documentation
├── jira/                       # JIRA evidence helper
│   ├── helper/                 # Go application
│   └── README.md               # Helper documentation
└── argocd/manifests/          # Kubernetes deployment manifests
    ├── deployment-*.yaml       # Service deployments
    ├── service-*.yaml          # Service definitions
    └── job-post-sync-evidence.yaml  # Post-deployment evidence job
```

## 🚀 Getting Started

### Prerequisites

- **JFrog Platform**: Artifactory + AppTrust instance
- **GitHub Repository**: With Actions enabled
- **Docker**: For local testing and development
- **Required Access**: JFrog, SonarQube, JIRA, and GitHub tokens

### GitHub Configuration

#### Required Secrets

| Secret | Description | Example |
|--------|-------------|---------|
| `JF_ACCESS_TOKEN` | JFrog access token with read/write permissions | `cmVmdGtuOjAxOjE2...` |
| `JFROG_CLI_SIGNING_KEY` | Private key for evidence signing | `-----BEGIN PRIVATE KEY-----...` |
| `SONAR_TOKEN` | SonarQube authentication token | `squ_1234567890abcdef...` |
| `JIRA_API_TOKEN` | JIRA API token for issue tracking | `ATATT3xFfGF0...` |
| `ARTIFACTORY_ACCESS_TOKEN` | Artifactory access token | `cmVmdGtuOjAxOjE2...` |
| `DEVELOCITY_ACCESS_KEY` | Gradle Develocity access key | `gradle-develocity-key...` |

#### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `JF_URL` | JFrog platform URL | `https://mycompany.jfrog.io` |
| `JF_USER` | JFrog username | `admin` |
| `DOCKER_REGISTRY` | Docker registry URL | `mycompany.jfrog.io/quotopia-dev-docker` |
| `JFROG_CLI_KEY_ALIAS` | Key alias for evidence signing | `my-signing-key` |
| `JIRA_URL` | JIRA instance URL | `https://mycompany.atlassian.net` |
| `JIRA_USERNAME` | JIRA username | `user@company.com` |
| `ARTIFACTORY_URL` | Artifactory URL | `https://mycompany.jfrog.io/artifactory` |

### Running the Demo

#### Step-by-Step Process

1. **Make Changes**: Modify any service code
2. **Push to Main**: Trigger individual service CI workflows
3. **Create Application Version**: Manually run the application versioning workflow
4. **Promote to QA**: Manually run the QA promotion workflow (includes E2E tests)
5. **Release to PROD**: Manually run the production release workflow (validates with AppTrust)

#### Workflow Execution Order

```bash
# 1. Code changes trigger individual service builds
git push origin main

# 2. Manually trigger application version creation
# GitHub Actions → Create Application Version

# 3. Manually trigger QA promotion with E2E testing
# GitHub Actions → Promote Application Version

# 4. Manually trigger production release
# GitHub Actions → Release Application Version
```

## 🔄 Promotion Flow

The complete promotion flow demonstrates evidence-driven deployment:

```
Code Push → Service CI → Build + Evidence → Application Version (DEV)
    ↓
Promote to QA → E2E Tests → Test Evidence → QA Validation
    ↓
Release to PROD ← AppTrust Gating ← Evidence Validation ← All Gates Pass
    ↓
ArgoCD Deployment → Production Environment
```

### Flow Details

1. **Development Stage**:
   - Individual services build independently
   - Each build creates evidence (tests, security scans, quality metrics)
   - Artifacts stored in Artifactory with complete metadata

2. **QA Stage**:
   - Application version combines all service builds
   - E2E tests validate integration
   - Test evidence attached to release bundle
   - Manual approval for promotion

3. **Production Stage**:
   - AppTrust validates all evidence gates
   - Security, quality, and test evidence must pass
   - ArgoCD deployment manifests updated
   - Production deployment triggered

## 🧪 Testing Locally

### Running Individual Services

#### Quote of Day Service
```bash
cd quoteofday
mvn spring-boot:run
# Service available at http://localhost:8001
```

#### AI Translation Service
```bash
cd translate
pip install -r requirements.txt
python app.py
# Service available at http://localhost:8002
```

#### Quotopia UI
```bash
cd quotopia-ui
# Open index.html in browser or serve with any web server
python -m http.server 8080
# UI available at http://localhost:8080
```

### Running E2E Tests

```bash
cd e2e-tests
npm ci
npm run test:report
# Generates test-report.md and test-report.json
```

## 🚢 ArgoCD Integration

The project includes ArgoCD integration for production deployments:

### Post-Sync Evidence Job
- **File**: `argocd/manifests/job-post-sync-evidence.yaml`
- **Purpose**: Creates evidence after successful deployment
- **Trigger**: ArgoCD post-sync hook
- **Evidence**: Deployment confirmation and environment validation

### Deployment Manifests
- **Services**: Kubernetes service definitions for all three applications
- **Deployments**: Container deployment specifications
- **Updates**: Automatically updated during PROD releases with new image versions

## 📚 Component Documentation

For detailed information about each component, refer to the individual README files:

- **[Quote of Day Service](quoteofday/README.md)** - Java Spring Boot service documentation
- **[AI Translation Service](translate/README.md)** - Python FastAPI service documentation  
- **[Quotopia UI](quotopia-ui/README.md)** - Static website documentation
- **[E2E Tests](e2e-tests/README.md)** - Cypress testing framework documentation
- **[JIRA Evidence Helper](jira/README.md)** - JIRA integration and evidence creation

## 🔧 Troubleshooting

### Common Issues

1. **Build Failures**: Check GitHub secrets and variables configuration
2. **Evidence Creation Errors**: Verify JFrog CLI signing key setup
3. **E2E Test Failures**: Ensure all services are running and accessible
4. **Promotion Failures**: Check AppTrust gating rules and evidence requirements

### Debugging Steps

1. Check GitHub Actions logs for detailed error messages
2. Verify JFrog platform connectivity and permissions
3. Validate Docker registry access and image availability
4. Review evidence creation logs in JFrog AppTrust

## 📄 License

This project is licensed under the MIT License - see the individual component README files for specific licensing information.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run the test suite
6. Submit a pull request

## 📞 Support

For questions about this demo or JFrog Evidence integration:
- Review the component-specific README files
- Check GitHub Actions workflow logs
- Consult JFrog documentation for platform-specific issues
