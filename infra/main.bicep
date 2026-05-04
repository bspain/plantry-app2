targetScope = 'resourceGroup'

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

@description('Environment name')
@allowed(['dev', 'prod'])
param environmentName string

@description('Azure region for all resources (except Static Web Apps, which has limited regions)')
param location string = resourceGroup().location

@description('''
Azure region for Static Web Apps.
Must be one of the supported SWA regions:
  centralus, eastus2, eastasia, westeurope, westus2,
  southeastasia, northeurope, canadacentral, brazilsouth, koreacentral, australiaeast.
Defaults to eastus2.
''')
param swaLocation string = 'eastus2'

@description('Pre-seeded household document ID — auto-provisioned users are assigned to this household')
param householdId string

@description('SPA redirect URIs for the Entra ID app registration (localhost + SWA production URL)')
param spaRedirectUris array = ['http://localhost:5173']

// ---------------------------------------------------------------------------
// Naming — all names derived from a stable prefix + resource-group-unique suffix
// Constraints respected:
//   Cosmos   : 3–44 chars, lowercase alphanumeric + hyphens
//   Key Vault: 3–24 chars, alphanumeric + hyphens
//   Storage  : 3–24 chars, lowercase alphanumeric only (no hyphens)
// ---------------------------------------------------------------------------

var prefix = 'plantry${environmentName}'
var uniqueSuffix = uniqueString(resourceGroup().id)

var cosmosAccountName = '${prefix}-cosmos-${take(uniqueSuffix, 8)}'
var pubSubName = '${prefix}-pubsub'
var keyVaultName = take('${prefix}kv${uniqueSuffix}', 24)
var functionsName = '${prefix}-api'
var storageAccountName = take('${prefix}sa${uniqueSuffix}', 24)
var swaName = '${prefix}-web'

// ---------------------------------------------------------------------------
// Cosmos DB
// ---------------------------------------------------------------------------
module cosmos './modules/cosmos.bicep' = {
  name: 'cosmos'
  params: {
    accountName: cosmosAccountName
    location: location
  }
}

// ---------------------------------------------------------------------------
// Web PubSub
// ---------------------------------------------------------------------------
module pubsub './modules/pubsub.bicep' = {
  name: 'pubsub'
  params: {
    name: pubSubName
    location: location
  }
}

// ---------------------------------------------------------------------------
// Functions App (deployed before Key Vault so the managed identity principal
// ID is available for the Key Vault RBAC role assignment)
// ---------------------------------------------------------------------------
module functions './modules/functions.bicep' = {
  name: 'functions'
  params: {
    name: functionsName
    storageAccountName: storageAccountName
    location: location
    keyVaultName: keyVaultName
    householdId: householdId
    corsAllowedOrigins: [
      'http://localhost:5173'
      'https://${staticWebApp.outputs.defaultHostname}'
    ]
  }
}

// ---------------------------------------------------------------------------
// Key Vault — stores Cosmos + PubSub connection strings, grants Functions access
// ---------------------------------------------------------------------------
module keyVault './modules/keyVault.bicep' = {
  name: 'keyVault'
  params: {
    name: keyVaultName
    location: location
    cosmosConnectionString: cosmos.outputs.connectionString
    pubSubConnectionString: pubsub.outputs.connectionString
    functionsPrincipalId: functions.outputs.principalId
  }
}

// ---------------------------------------------------------------------------
// Static Web App
// ---------------------------------------------------------------------------
module staticWebApp './modules/staticWebApp.bicep' = {
  name: 'staticWebApp'
  params: {
    name: swaName
    location: swaLocation
  }
}

// ---------------------------------------------------------------------------
// App Registration (Entra ID — personal Microsoft accounts)
// Requires Microsoft.Graph extension + Application.ReadWrite.OwnedBy permission
// ---------------------------------------------------------------------------
module appRegistration './modules/appRegistration.bicep' = {
  name: 'appRegistration'
  params: {
    displayName: 'Plantry App 2 (${environmentName})'
    spaRedirectUris: union(spaRedirectUris, ['https://${staticWebApp.outputs.defaultHostname}'])
  }
}

// ---------------------------------------------------------------------------
// Outputs — reference these values when configuring CI/CD secrets and local dev
// ---------------------------------------------------------------------------
output staticWebAppUrl string = 'https://${staticWebApp.outputs.defaultHostname}'
output staticWebAppName string = staticWebApp.outputs.name
output functionAppName string = functions.outputs.name
output functionAppUrl string = 'https://${functions.outputs.defaultHostname}'
output cosmosAccountName string = cosmos.outputs.accountName
output keyVaultName string = keyVault.outputs.name
output keyVaultUri string = keyVault.outputs.uri
output appRegistrationClientId string = appRegistration.outputs.clientId
