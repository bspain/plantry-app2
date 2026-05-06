// The Microsoft.Graph Bicep extension enables creating Entra ID resources
// (app registrations, service principals) from an ARM/Bicep deployment.
// The deploying service principal requires the Microsoft Graph API permission:
//   Application.ReadWrite.OwnedBy  (Application type, admin-consented)
extension microsoftGraph

@description('Display name for the Entra ID app registration')
param displayName string

@description('SPA redirect URIs — include localhost for local dev and the SWA hostname for each environment')
param spaRedirectUris array

// ---------------------------------------------------------------------------
// App Registration — personal Microsoft accounts (consumers tenant)
// signInAudience: PersonalMicrosoftAccount → authority login.microsoftonline.com/consumers
// ---------------------------------------------------------------------------
resource application 'Microsoft.Graph/applications@v1.0' = {
  displayName: displayName
  signInAudience: 'PersonalMicrosoftAccount'

  // SPA redirect URIs (PKCE, no client secret required)
  spa: {
    redirectUris: spaRedirectUris
  }

  // Request User.Read delegated permission from Microsoft Graph
  requiredResourceAccess: [
    {
      resourceAppId: '00000003-0000-0000-c000-000000000000' // Microsoft Graph
      resourceAccess: [
        {
          id: 'e1fe6dd8-ba31-4d61-89e7-88639da4683d' // User.Read (delegated)
          type: 'Scope'
        }
      ]
    }
  ]
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------
@description('Application (client) ID — set as AZURE_CLIENT_ID in Functions app settings and MSAL config')
output clientId string = application.appId

@description('Object ID of the app registration (Entra ID)')
output objectId string = application.id
