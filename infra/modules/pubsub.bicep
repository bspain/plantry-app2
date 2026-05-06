@description('Azure Web PubSub resource name (3–63 alphanumeric or hyphens)')
param name string

@description('Azure region for Web PubSub')
param location string

// ---------------------------------------------------------------------------
// Azure Web PubSub — Free tier, 1 unit
// ---------------------------------------------------------------------------
resource webPubSub 'Microsoft.SignalRService/webPubSub@2023-02-01' = {
  name: name
  location: location
  sku: {
    name: 'Free_F1'
    tier: 'Free'
    capacity: 1
  }
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------
output name string = webPubSub.name

@description('Primary connection string for Key Vault storage')
@secure()
output connectionString string = webPubSub.listKeys().primaryConnectionString
