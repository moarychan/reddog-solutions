param location string
param springAppsName string
param logAnalyticsName string
param appInsightsName string
// Deployment variables
@secure()
param azureCosmosDBUri string
@secure()
param azureCosmosDBKey string
param azureCosmosDBDatabaseName string = 'reddog'
param kafkaBootstrapServers string
param kafkaSecurityProtocol string = 'SASL_SSL'
param kafkaSaslMechanism string = 'PLAIN'
param kafkaTopicName string = 'reddog'
param mysqlURL string
@secure()
param mysqlUser string = 'reddog'
@secure()
param mysqlPassword string
param azureRedisHost string
param azureRedisPort string = '6380'
@secure()
param azureRedisAccessKey string
param azureStorageAccountName string
@secure()
param azureStorageAccountKey string
param azureStorageEndpoint string
@secure()
param serviceBusConnectionString string

var credentials = loadJsonContent('credentials.json')
var envVariables = {
    AZURECOSMOSDBURI: azureCosmosDBUri
    AZURECOSMOSDBKEY: azureCosmosDBKey
    AZURECOSMOSDBDATABASENAME: azureCosmosDBDatabaseName
    KAFKASASLJAASCONFIG: credentials.kafkaSaslJaasConfig
    KAFKABOOTSTRAPSERVERS: kafkaBootstrapServers
    KAFKASECURITYPROTOCOL: kafkaSecurityProtocol
    KAFKASASLMECHANISM: kafkaSaslMechanism
    KAFKATOPICNAME: kafkaTopicName
    MYSQLURL: mysqlURL
    MYSQLUSER: mysqlUser
    MYSQLPASSWORD: mysqlPassword
    AZUREREDISHOST: azureRedisHost
    AZUREREDISPORT: azureRedisPort
    AZUREREDISACCESSKEY: azureRedisAccessKey
    AZURESTORAGEACCOUNTNAME: azureStorageAccountName
    AZURESTORAGEACCOUNTKEY: azureStorageAccountKey
    AZURESTORAGEENDPOINT: azureStorageEndpoint
    KAFKATOPICGROUP: 'order-service'
    KAFKACONSUMERGROUPID: 'order-service'
    SERVICEBUSCONNECTIONSTRING: serviceBusConnectionString
    KAFKACOMPLETEDORDERSTOPIC: 'make-line-completed'
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    Request_Source: 'rest'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource springAppsService 'Microsoft.AppPlatform/Spring@2022-12-01' = {
  name: springAppsName
  location: location
  sku: {
    name: 'S0'
    tier: 'Standard'
  }
}

resource springAppsMonitoringSettings 'Microsoft.AppPlatform/Spring/monitoringSettings@2022-12-01' = {
  name: 'default'
  parent: springAppsService
  properties: {
    traceEnabled: true
    appInsightsInstrumentationKey: appInsights.properties.InstrumentationKey
  }
}

resource springAppsDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'monitoring'
  scope: springAppsService
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'ApplicationConsole'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: false
        }
      }
    ]
  }
}

resource orderService 'Microsoft.AppPlatform/Spring/apps@2022-12-01' = {
  name: 'order-service'
  location: location
  parent: springAppsService
}

resource orderServiceDeployment 'Microsoft.AppPlatform/Spring/apps/deployments@2022-12-01' = {
  name: 'default'
  sku: {
    capacity: 2
    name: 'S0'
    tier: 'Standard'
  }
  parent: orderService
  properties: {
    // active: true
    deploymentSettings: {
      environmentVariables: envVariables
      resourceRequests: {
        cpu: '2'
        memory: '4Gi'
      }
    }
    source: {
      version: '0.0.1-SNAPSHOT'
      type: 'Jar'
      // relativePath: './../../order-service/'
      runtimeVersion: '17'
    }
  }
}

output workspaceId string = logAnalyticsWorkspace.id
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
