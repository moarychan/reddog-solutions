# Functions

escape_double_quotes() {
    local input=$1
    input="${input//\"/\\\"}"
    echo "$input"
}

deploy_azure_spring_apps () {
    # build backend projects
    # mvn -f ../pom.xml clean package -DskipTests 
    # export environment variables
    echo $VARIABLES_FILE
    . $VARIABLES_FILE
    echo $AZURECOSMOSDBURI
#    kafkasasljaasconfig_escape=$(escape_double_quotes "$KAFKASASLJAASCONFIG")
#    echo $kafkasasljaasconfig_escape
    # Bicep deploy ASA
    az deployment group create \
    --name reddog-asa \
    --mode Incremental \
    --resource-group $RG \
    --template-file .././deploy/bicep/asa.bicep \
    --parameters uniqueServiceName=$UNIQUE_SERVICE_NAME \
    --parameters azureCosmosDBUri=$AZURECOSMOSDBURI \
    --parameters azureCosmosDBKey=$AZURECOSMOSDBKEY \
    --parameters azureCosmosDBDatabaseName=$AZURECOSMOSDBDATABASENAME \
    --parameters kafkaBootstrapServers=$KAFKABOOTSTRAPSERVERS \
    --parameters kafkaSecurityProtocol=$KAFKASECURITYPROTOCOL \
    --parameters kafkaSaslMechanism=$KAFKASASLMECHANISM \
    --parameters kafkaTopicName=$KAFKATOPICNAME \
    --parameters mysqlURL=$MYSQLURL \
    --parameters mysqlUser=$MYSQLUSER \
    --parameters mysqlPassword=$MYSQLPASSWORD \
    --parameters azureRedisHost=$AZUREREDISHOST \
    --parameters azureRedisPort=$AZUREREDISPORT \
    --parameters azureRedisAccessKey=$AZUREREDISACCESSKEY \
    --parameters azureStorageAccountName=$AZURESTORAGEACCOUNTNAME \
    --parameters azureStorageAccountKey=$AZURESTORAGEACCOUNTKEY \
    --parameters azureStorageEndpoint=$AZURESTORAGEENDPOINT \
    --parameters serviceBusConnectionString=$SERVICEBUSCONNECTIONSTRING \
    -o table --verbose
}

deploy_azure_kubernetes_service () {
    # Bicep deploy AKS
    az deployment group create \
    --name reddog-aks \
    --mode Incremental \
    --only-show-errors \
    --resource-group $RG \
    --template-file .././deploy/bicep/aks.bicep \
    --parameters aksName=$AKS_NAME \
    --parameters nodeCount=5 -o table
}

check_for_azure_login () {
    echo 'Checking to ensure logged into Azure CLI'
    AZURE_LOGIN=0 
    # run a command against Azure to check if we are logged in already.
    az group list -o table
    # save the return code from above. Anything different than 0 means we need to login
    AZURE_LOGIN=$?

    if [[ ${AZURE_LOGIN} -ne 0 ]]; then
    # not logged in. Initiate login process
        az login --use-device-code
        export AZURE_LOGIN
    fi
}
