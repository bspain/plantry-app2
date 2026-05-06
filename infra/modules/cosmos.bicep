@description('Cosmos DB account name (globally unique, 3–44 lowercase alphanumeric or hyphens)')
param accountName string

@description('Azure region for the Cosmos DB account')
param location string

// ---------------------------------------------------------------------------
// Cosmos DB account (serverless, NoSQL API)
// ---------------------------------------------------------------------------
resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: accountName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    capabilities: [
      { name: 'EnableServerless' }
    ]
    enableFreeTier: false
    disableKeyBasedMetadataWriteAccess: false
  }
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------
resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' = {
  parent: cosmosAccount
  name: 'plantry'
  properties: {
    resource: { id: 'plantry' }
  }
}

// ---------------------------------------------------------------------------
// Containers — partition key strategy from docs/plan.md
// ---------------------------------------------------------------------------
var containerDefs = [
  { name: 'Users', partitionKey: '/id' }
  { name: 'Households', partitionKey: '/id' }
  { name: 'Weeks', partitionKey: '/householdId' }
  { name: 'Meals', partitionKey: '/weekId' }
  { name: 'GroceryItems', partitionKey: '/weekId' }
]

resource containers 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = [
  for c in containerDefs: {
    parent: database
    name: c.name
    properties: {
      resource: {
        id: c.name
        partitionKey: {
          paths: [c.partitionKey]
          kind: 'Hash'
        }
      }
    }
  }
]

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------
output accountName string = cosmosAccount.name

@description('Primary connection string for Key Vault storage')
@secure()
output connectionString string = cosmosAccount.listConnectionStrings().connectionStrings[0].connectionString
