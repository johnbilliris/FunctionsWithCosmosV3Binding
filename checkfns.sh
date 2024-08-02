#!/bin/bash
echo "Starting check for Cosmos DB V3 Bindings"
functionApps=$(az functionapp list --query "[].{name: name, resourceGroup: resourceGroup}" --output json)
echo "$functionApps" | jq -c '.[]' | while read -r functionAppDefinition; do
    name=$(echo "$functionAppDefinition" | jq -r '.name')
    resourceGroup=$(echo "$functionAppDefinition" | jq -r '.resourceGroup')
    # echo "$name, ResourceGroup: $resourceGroup"

    functionApp=$(az functionapp function list --resource-group "$resourceGroup" --name "$name" --output json )
    # echo "$functionApp"

    echo "$functionApp" | jq -c '.[]' | while read -r function; do
        # echo "$function"
        functionName=$(echo "$function" | jq -r '.name')
        # echo "  $functionName"
        echo "$function" | jq -c '.config.bindings[]' | while read -r binding; do
            type=$(echo "$binding" | jq -r '.type')
            connectionStringSetting=$(echo "$binding" | jq -r '.connectionStringSetting')
            # echo "      Binding type: $type, ConnectionStringSetting: $connectionStringSetting"
            
            if [[ ("$type" == "cosmosDBTrigger" || "$type" == "cosmosDB") && (-z "$connectionStringSetting") ]]; then
                echo "*** FOUND Cosmos V3 Binding ***: Function App Name: $name, ResourceGroup: $resourceGroup, Function Name: $functionName"
            fi
        done
    done
done
echo "Finished check for Cosmos DB V3 Bindings"