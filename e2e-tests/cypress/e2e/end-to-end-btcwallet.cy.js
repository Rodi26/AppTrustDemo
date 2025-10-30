describe('BTCWallet End-to-End Tests', () => {
  const btcWalletServiceUrl = 'http://localhost:8001'
  const uiServiceUrl = 'http://localhost:8081'
  
  before(() => {
    // Check if services are running, if not start them
    cy.task('startServicesIfNeeded', {
      btcWalletServiceUrl,
      uiServiceUrl
    })
  })

  beforeEach(() => {
    // Wait for both services to be ready
    cy.waitForService(btcWalletServiceUrl, '/actuator/health')
    cy.waitForService(uiServiceUrl, '/')
  })

  it('should display the BTCWallet UI with proper structure', () => {
    cy.visit(uiServiceUrl)
    
    // Check main container structure
    cy.get('[data-testid="wallet-container"]').should('be.visible')
    
  })

})
