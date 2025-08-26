#!/usr/bin/env node

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('🚀 Starting Cypress E2E Tests');
console.log('=' * 50);

// Get service URLs from environment
const quoteUrl = process.env.QUOTE_SERVICE_URL || 'http://quote-service:8080';
const translationUrl = process.env.TRANSLATION_SERVICE_URL || 'http://translation-service:8000';

console.log('📋 Test Configuration:');
console.log(`   Quote Service URL: ${quoteUrl}`);
console.log(`   Translation Service URL: ${translationUrl}`);
console.log();

// Wait for services to be ready
function waitForService(url, endpoint, serviceName, maxRetries = 30) {
  console.log(`⏳ Waiting for ${serviceName} at ${url}${endpoint}...`);
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = execSync(`curl -s -f ${url}${endpoint}`, { encoding: 'utf8' });
      console.log(`✅ ${serviceName} is ready!`);
      return true;
    } catch (error) {
      if (i < maxRetries - 1) {
        console.log(`   Attempt ${i+1}/${maxRetries} - ${serviceName} not ready yet, retrying in 2s...`);
        execSync('sleep 2');
      }
    }
  }
  
  console.log(`❌ ${serviceName} failed to start after ${maxRetries} attempts`);
  return false;
}

// Wait for services
const quoteReady = waitForService(quoteUrl, '/actuator/health', 'Quote Service');
const translationReady = waitForService(translationUrl, '/health', 'Translation Service');

if (!quoteReady || !translationReady) {
  console.log('❌ Services failed to start');
  process.exit(1);
}

console.log('🎉 All services are ready!');
console.log('🧪 Running Cypress E2E tests...');
console.log('=' * 50);

// Run Cypress tests
try {
  execSync('npm run test', { stdio: 'inherit' });
  console.log('✅ Cypress E2E tests completed successfully!');
  
  // Generate test summary
  const resultsPath = path.join(__dirname, 'cypress/results/results.json');
  if (fs.existsSync(resultsPath)) {
    const results = JSON.parse(fs.readFileSync(resultsPath, 'utf8'));
    
    console.log('\n📊 Test Summary:');
    console.log(`   Total Tests: ${results.runs?.[0]?.stats?.tests || 0}`);
    console.log(`   Passed: ${results.runs?.[0]?.stats?.passes || 0}`);
    console.log(`   Failed: ${results.runs?.[0]?.stats?.failures || 0}`);
    console.log(`   Duration: ${results.runs?.[0]?.stats?.duration || 0}ms`);
  }
  
  process.exit(0);
} catch (error) {
  console.log('❌ Cypress E2E tests failed!');
  process.exit(1);
}
