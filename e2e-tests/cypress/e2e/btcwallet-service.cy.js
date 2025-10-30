describe('BTCWallet Service E2E Tests', () => {
  const btcWalletServiceUrl = Cypress.env('btcWalletServiceUrl')

  beforeEach(() => {
    // Wait for BTCWallet service to be ready
    cy.waitForService(btcWalletServiceUrl, '/actuator/health')
  })

  it('should have healthy BTCWallet service', () => {
    cy.request('GET', `${btcWalletServiceUrl}/actuator/health`)
      .then((response) => {
        expect(response.status).to.eq(200)
        expect(response.body.status).to.eq('UP')
      })
  })

  it('should return health status from API endpoint', () => {
    cy.request('GET', `${btcWalletServiceUrl}/api/btcwallet/health`)
      .then((response) => {
        expect(response.status).to.eq(200)
      })
  })

  it('should return first wallet', () => {
    cy.request('GET', `${btcWalletServiceUrl}/api/btcwallet/first`)
      .then((response) => {
        expect(response.status).to.eq(200)
        expect(response.body).to.have.property('address')
        // expect(response.body).to.have.property('author')
        // expect(response.body.text).to.be.a('string')
        // expect(response.body.author).to.be.a('string')
      })
  })
})
