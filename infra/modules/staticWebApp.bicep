@description('Azure Static Web Apps resource name (1–40 alphanumeric or hyphens)')
param name string

@description('''
Azure region for the Static Web App.
Allowed values: centralus, eastus2, eastasia, westeurope, westus2, southeastasia, northeurope, canadacentral, brazilsouth, koreacentral, australiaeast.
''')
param location string

// ---------------------------------------------------------------------------
// Azure Static Web Apps — Free tier
// The frontend React PWA calls the standalone Functions App URL directly.
// ---------------------------------------------------------------------------
resource staticWebApp 'Microsoft.Web/staticSites@2023-01-01' = {
  name: name
  location: location
  sku: {
    name: 'Free'
    tier: 'Free'
  }
  properties: {
    buildProperties: {
      appLocation: 'apps/web'
      outputLocation: 'dist'
    }
  }
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------
output name string = staticWebApp.name
output defaultHostname string = staticWebApp.properties.defaultHostname
output resourceId string = staticWebApp.id
