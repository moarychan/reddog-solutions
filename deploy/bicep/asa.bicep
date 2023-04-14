// Params
param uniqueServiceName string
param springAppsName string = 'asa${uniqueServiceName}'
param logAnalyticsName string = 'la${uniqueServiceName}'
param appInsightsName string = 'appins${uniqueServiceName}'
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
