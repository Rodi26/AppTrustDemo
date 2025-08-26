const { defineConfig } = require('cypress')

module.exports = defineConfig({
  e2e: {
    baseUrl: 'http://quote-service:8080',
    supportFile: 'cypress/support/e2e.js',
    specPattern: 'cypress/e2e/**/*.cy.js',
    video: false,
    screenshotOnRunFailure: false,
    reporter: 'json',
    reporterOptions: {
      outputFile: 'cypress/results/results.json'
    },
    env: {
      quoteServiceUrl: 'http://quote-service:8080',
      translationServiceUrl: 'http://translation-service:8000'
    }
  },
  reporter: 'json',
  reporterOptions: {
    outputFile: 'cypress/results/results.json'
  }
})
