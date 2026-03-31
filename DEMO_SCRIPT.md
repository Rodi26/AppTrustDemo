# BTC Wallet AppTrust Demo — SA Script

## Overview (2 min)

This demo showcases JFrog AppTrust with a realistic multi-service application: a Bitcoin Wallet composed of three services — `btcwallet` (Go backend), `btcwallet-ui` (React frontend), and `ai-translate` (Python AI microservice).

The core story is **evidence-driven software promotion**: every stage transition (DEV → QA → STAGING/PreProd → PROD) is governed by a lifecycle gate that requires verifiable evidence — vulnerability scan results, E2E test reports, and change approval records from ServiceNow. No evidence, no promotion.

Key platform capabilities shown:
- AppTrust application versions aggregating multiple service builds
- Lifecycle gate policies evaluating evidence at each stage boundary
- Full cryptographic audit trail from commit to production

---

## Prerequisites

- **GitHub repo**: `Rodi26/AppTrustDemo` with GitHub Actions enabled
- **JFrog Platform**: `rodolphefplus.jfrog.io` — project `btcwallet`
- **GitHub Variables set**: `JF_URL`, `APPLICATION_NAME`, `APPLICATION_KEY`, `APPLICATION_DISPLAY_NAME`, `JF_PROJECT`, `TARGET_STAGE` (QA), `PREPROD_STAGE` (PreProd), `DOCKER_REGISTRY_PREFIX`, `PROJECT_DOCKER_QA_REPO`, `JFROG_CLI_KEY_ALIAS`
- **GitHub Secrets set**: `JF_ACCESS_TOKEN`, `JFROG_CLI_SIGNING_KEY`
- **JFrog Platform**: AppTrust application `btcwallet` created, lifecycle stages DEV / QA / PreProd / PROD configured with gate policies
- **OIDC provider** `btcwallet-gh` configured in JFrog for keyless signing

---

## Demo Flow

### Step 1 — Trigger service builds (3-5 min)

**What to trigger:**
In GitHub Actions, manually trigger each of the three service CI workflows (or push to `main` to trigger them automatically):
1. `BTC Wallet Service CI` — builds and publishes the Go backend Docker image + build info
2. `BTCWallet UI Service CI` — builds and publishes the React frontend Docker image + build info
3. `AI Translate Service CI` — builds and publishes the Python AI service Docker image + build info

Each workflow: checks out code, builds a Docker image, pushes it to the `btcwallet` project DEV Docker repository in Artifactory, publishes build info, and collects a Xray vulnerability scan.

**What to show in the JFrog UI:**
- Artifactory: `btcwallet-docker-dev-local` repository — new image tags per service
- Build Info: three build records (`btcwallet`, `btcwallet-ui`, `ai-translate`) with their artifact lists
- Xray: vulnerability scan attached to each image (CVEs, severity breakdown)

**Talking point:** "Each service is independently built and scanned. AppTrust will aggregate these three builds into a single application version — creating a holistic, immutable snapshot of what we are about to promote."

---

### Step 2 — Create Application Version (1-2 min)

**What to trigger:**
Manually trigger `Create Application Version` in GitHub Actions.

The workflow:
1. Queries Artifactory to find the latest build number for each of the three services
2. Calls `jf apptrust version-create` to create a new application version (auto-incremented integer) linking all three builds
3. Promotes the version to the `DEV` stage
4. Creates gate certification evidence for the DEV entry gate

**What to show in the JFrog UI:**
- AppTrust → Applications → `btcwallet` → Versions: new version appears, stage shows `DEV`
- Evidence panel on the version: gate certification evidence from the `apptrust` provider
- Sources tab: three build info sources linked to the version

**Talking point:** "This is the application version — a single, traceable unit that groups the three services. Every piece of evidence we collect will be attached to this version, and every gate policy will evaluate against it."

---

### Step 3 — Promote to QA (5-7 min)

**What to trigger:**
Manually trigger `Promote Latest Application Version` (the `promote-application-version.yml` workflow). This workflow targets the QA stage via the `TARGET_STAGE` variable.

The workflow:
1. Fetches the latest application version and its current stage
2. Creates DEV exit gate certification evidence
3. Polls the promotion dry-run (up to 10 attempts, 15s intervals) waiting for evidence to propagate — this replaces the old hard-coded 45s sleep
4. Once the dry-run passes, performs the actual promotion to QA
5. Runs the full E2E test suite (Cypress/Mocha) against the QA Docker environment
6. Submits E2E test results as evidence with predicate type `https://cypress.io/evidence/e2e/v1`

**What to show in the JFrog UI:**
- GitHub Actions: the polling loop attempting the dry-run — highlight the "Evidence propagated. Dry-run passed on attempt N" message
- AppTrust version: stage advances to `QA`
- Evidence panel: E2E test evidence from the `cypress` provider — click into it to show the test report markdown with pass/fail counts
- Gate policy evaluation log: the DEV exit gate policy was evaluated and passed before promotion was allowed

**Talking point:** "The gate won't open unless the evidence exists. The dry-run polling is a real-time readiness check — we only proceed when AppTrust confirms the policy passes. No guessing, no fixed waits."

---

### Step 4 — Promote to PreProd/STAGING (1-2 min)

**What to trigger:**
Manually trigger `Promote Application to PreProd` (`promote-application-version-preprod.yml`).

The workflow:
1. Fetches the latest application version
2. Runs a diagnostic dry-run promotion to check the PreProd entry gate
3. **Creates ServiceNow change approval evidence BEFORE promotion** — this is the key change: the SNOW evidence now acts as a gate requirement, not an afterthought
4. Promotes the version to `PreProd`
5. Creates the PreProd gate certification evidence after promotion

**What to show in the JFrog UI:**
- Evidence panel: ServiceNow approval evidence (`https://servicenow.com/approval/v1`) created before the promotion step
- AppTrust version: stage advances to `PreProd`/`STAGING`
- Gate policy: show that the QA exit gate policy required the SNOW evidence — the promotion succeeded because the evidence was in place

**Talking point:** "In a real enterprise, the ServiceNow change ticket is the gate. We simulate that here: the SNOW evidence is created first, so when AppTrust evaluates the QA exit gate, it finds the approval record. The promotion is conditional on that approval existing."

---

### Step 5 — Release to PROD (1 min)

**What to trigger:**
Manually trigger `Release Application` (`release-application-version.yml`).

The workflow promotes the version from `PreProd` to `PROD`, evaluating the final gate policy which requires the full evidence chain to be intact.

**What to show in the JFrog UI:**
- AppTrust version: final stage shows `PROD`
- Full evidence timeline on the version: all evidence types visible — gate certifications (DEV, QA, PreProd), E2E test results, ServiceNow approval, vulnerability scan data
- Audit trail: every stage transition is timestamped and signed

**Talking point:** "This is the complete audit trail — from the first commit to production. Every decision was evidence-backed and policy-gated. This is what compliance, security, and operations teams need: not just a deployment log, but proof of what was validated at every step."

---

## Key Demo Moments (what to highlight)

### Evidence panel per service and version
Navigate to AppTrust → Applications → `btcwallet` → select the version → Evidence tab. Show:
- Multiple evidence types side by side: vulnerability, E2E tests, SNOW approval, gate certifications
- Each evidence item is signed and has a verifiable predicate
- Evidence is immutable — it cannot be altered after creation

### Gate policy evaluations
Navigate to AppTrust → Policies (or Lifecycle policies in the btcwallet project). Show:
- DEV exit gate: requires gate certification evidence
- QA exit gate: requires E2E test evidence with passing status
- PreProd entry gate: requires ServiceNow approval evidence
- PROD entry gate: full chain evaluation

Highlight: policies are declarative — the platform enforces them, not the pipeline script.

### ServiceNow change approval
Open the SNOW evidence predicate in the evidence panel. Show the `approval.json` payload — change number, approver, approval status, timestamp. This is the bridge between ITSM and the deployment pipeline.

### Full audit trail
On the version detail page, show the stage history timeline: DEV → QA → PreProd → PROD with timestamps. Every transition was gated. Every gate was evaluated. Every evaluation is on record.

---

## Troubleshooting

### "Could not retrieve a valid application version"
The `create-application-version.yml` workflow queries the AppTrust API for the latest version. If no version exists yet, it defaults to `0` and creates version `1`. If it fails:
- Verify `APPLICATION_NAME` variable matches the AppTrust application key exactly (case-sensitive)
- Verify `JF_ACCESS_TOKEN` has AppTrust read permissions in the `btcwallet` project

### "Dry-run failed — this indicates a policy/configuration issue"
This appears in `promote-application-version-preprod.yml`. Check:
- The `PREPROD_STAGE` GitHub variable matches the exact stage name configured in AppTrust (e.g. `PreProd`, not `PREPROD`)
- The PreProd stage has at least one entry gate policy configured in JFrog Platform → Lifecycle → Application Policies
- The `btcwallet` project has a Docker repository mapped to the PreProd stage

### "Max attempts reached. Proceeding anyway"
The polling loop in `promote-application-version.yml` tried 10 times (150s total) without the dry-run returning `"status":"success"`. This can mean:
- Evidence was created but the predicate type does not match what the gate policy expects — verify the policy rule references the correct predicate type
- The gate policy has no rules configured — an empty gate always evaluates as blocked
- A race condition with JFrog's internal indexing — re-run the workflow manually after 30s

### SNOW evidence step fails with "no such file or directory"
The `snow/approval.json` and `snow/approval.md` files may be stale or missing from the branch. The step has `continue-on-error: true` so the workflow will not stop, but the SNOW evidence will not be created — the PreProd gate may then block the promotion if it requires SNOW evidence. Refresh the `snow/` directory files with current change ticket data before re-running.

### E2E tests fail with Docker pull errors
The QA Docker registry path is composed from `DOCKER_REGISTRY_PREFIX` and `PROJECT_DOCKER_QA_REPO` variables. Verify:
- `DOCKER_REGISTRY_PREFIX` = `rodolphefplus.jfrog.io` (no trailing slash)
- `PROJECT_DOCKER_QA_REPO` = the QA virtual/local repo name in the `btcwallet` project
- The `JF_ACCESS_TOKEN` has read access to that repository

### Workflow does not auto-trigger after a service CI completes
The `workflow_run` trigger in `create-application-version.yml` fires when ANY of the three service CI workflows completes on `main`. Check:
- The completed workflow name matches exactly: `BTC Wallet Service CI`, `BTCWallet UI Service CI`, or `AI Translate Service CI`
- The branch that triggered the service CI is `main`
- GitHub Actions permissions allow `workflow_run` triggers (repository settings → Actions → General)
