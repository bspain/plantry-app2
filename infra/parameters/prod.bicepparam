using './main.bicep'

param environmentName = 'prod'
param location = 'eastus2'
param swaLocation = 'eastus2'

// Pre-seeded household document ID — must match the document seeded in Cosmos DB.
// Use the same value as dev unless you maintain a separate prod household seed.
param householdId = 'REPLACE_WITH_YOUR_HOUSEHOLD_ID'

// SPA redirect URIs — localhost is always included for local development.
// After the first prod deployment, add the prod SWA hostname here and redeploy
// so the app registration is updated with the production redirect URI.
// Example: 'https://proud-desert-012345.azurestaticapps.net'
param spaRedirectUris = [
  'http://localhost:5173'
]
