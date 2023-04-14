// Params
param uniqueServiceName string
param springAppsName string = 'asa${uniqueServiceName}'
param logAnalyticsName string = 'la${uniqueServiceName}'
param appInsightsName string = 'appins${uniqueServiceName}'

param location string = resourceGroup().location

module springApps 'modules/spring-apps.bicep' = {
  name: '${deployment().name}--asa'
  params: {
    springAppsName: springAppsName
    logAnalyticsName: logAnalyticsName
    appInsightsName: appInsightsName
    location: location
    azureCosmosDBUri: azureCosmosDBUri
    azureCosmosDBKey: azureCosmosDBKey
    azureCosmosDBDatabaseName: azureCosmosDBDatabaseName
    kafkaBootstrapServers: kafkaBootstrapServers
    kafkaSecurityProtocol: kafkaSecurityProtocol
    kafkaSaslMechanism: kafkaSaslMechanism
    kafkaTopicName: kafkaTopicName
    mysqlURL: mysqlURL
    mysqlUser: mysqlUser
    mysqlPassword: mysqlPassword
    azureRedisHost: azureRedisHost
    azureRedisPort: azureRedisPort
    azureRedisAccessKey: azureRedisAccessKey
    azureStorageAccountName: azureStorageAccountName
    azureStorageAccountKey: azureStorageAccountKey
    azureStorageEndpoint: azureStorageEndpoint
    serviceBusConnectionString: serviceBusConnectionString
  }
}

// Outputs
output logAnalyticsWorkspaceId string = springApps.outputs.workspaceId
output appInsightsInstrumentationKey string = springApps.outputs.appInsightsInstrumentationKey
