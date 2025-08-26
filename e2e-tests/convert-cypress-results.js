#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Read Cypress results
const cypressResultsPath = path.join(__dirname, 'cypress/results/results.json');
const outputPath = path.join(__dirname, 'cypress-results-converted.json');

if (!fs.existsSync(cypressResultsPath)) {
  console.error('❌ Cypress results file not found:', cypressResultsPath);
  process.exit(1);
}

try {
  const cypressResults = JSON.parse(fs.readFileSync(cypressResultsPath, 'utf8'));
  
  // Convert to JFrog evidence format
  const convertedResults = {
    test_run: {
      timestamp: new Date().toISOString(),
      framework: 'cypress',
      version: '13.6.0',
      environment: 'qa'
    },
    summary: {
      total: 0,
      passed: 0,
      failed: 0,
      skipped: 0,
      duration: 0
    },
    tests: [],
    metadata: {
      cypress_results: cypressResults
    }
  };

  // Extract test statistics from Cypress results
  if (cypressResults.runs && cypressResults.runs.length > 0) {
    const run = cypressResults.runs[0];
    const stats = run.stats || {};
    
    convertedResults.summary = {
      total: stats.tests || 0,
      passed: stats.passes || 0,
      failed: stats.failures || 0,
      skipped: stats.skipped || 0,
      duration: stats.duration || 0
    };

    // Extract individual test results
    if (run.tests) {
      convertedResults.tests = run.tests.map(test => ({
        name: test.title?.join(' > ') || 'Unknown Test',
        status: test.state || 'unknown',
        duration: test.duration || 0,
        error: test.error || null
      }));
    }
  }

  // Write converted results
  fs.writeFileSync(outputPath, JSON.stringify(convertedResults, null, 2));
  console.log('✅ Cypress results converted successfully');
  console.log(`📁 Output file: ${outputPath}`);
  console.log('📊 Summary:', convertedResults.summary);

} catch (error) {
  console.error('❌ Error converting Cypress results:', error.message);
  process.exit(1);
}
