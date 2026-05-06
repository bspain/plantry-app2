@description('Key Vault name (3–24 alphanumeric or hyphens, globally unique)')
param name string

@description('Azure region for the Key Vault')
param location string

@description('Cosmos DB primary connection string to store as a secret')
@secure()
param cosmosConnectionString string

@description('Web PubSub primary connection string to store as a secret')
@secure()
param pubSubConnectionString string

@description('Object (principal) ID of the Functions App system-assigned managed identity')
param functionsPrincipalId string

// ---------------------------------------------------------------------------
// Key Vault — RBAC-based access control
// ---------------------------------------------------------------------------
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enabledForDeployment: false
    enabledForTemplateDeployment: false
    enabledForDiskEncryption: false
  }
}

// ---------------------------------------------------------------------------
// Secrets
// ---------------------------------------------------------------------------
resource cosmosSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'CosmosConnectionString'
  properties: {
    value: cosmosConnectionString
  }
}

resource pubSubSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'PubSubConnectionString'
  properties: {
    value: pubSubConnectionString
  }
}

// ---------------------------------------------------------------------------
// RBAC: grant Functions App managed identity access to read secrets
// Role: Key Vault Secrets User (4633458b-17de-408a-b874-0445c86b69e6)
// ---------------------------------------------------------------------------
var keyVaultSecretsUserRoleId = '4633458b-17de-408a-b874-0445c86b69e6'

resource kvSecretsUserAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, functionsPrincipalId, keyVaultSecretsUserRoleId)
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretsUserRoleId)
    principalId: functionsPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------
output name string = keyVault.name
output uri string = keyVault.properties.vaultUri
