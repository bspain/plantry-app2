using './main.bicep'

param environmentName = 'dev'
param location = 'eastus2'
param swaLocation = 'eastus2'

// Pre-seeded household document ID — must match the document seeded in Cosmos DB.
// Update this value if you change the household seed document.
param householdId = 'REPLACE_WITH_YOUR_HOUSEHOLD_ID'

// SPA redirect URIs — localhost is always included for local development.
// After the first deployment the SWA hostname output is automatically appended
// by main.bicep, so no manual change is needed for dev.
param spaRedirectUris = [
  'http://localhost:5173'
]
