#criação da conta


data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "config_cliente" {
}

resource "azurerm_role_assignment" "atribuicao_de_funcao" {
  scope                = azurerm_storage_account.storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.config_cliente.object_id
}

resource "azurerm_data_factory" "data_factory_bs" {
  name                = "df-blob-storage"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_data_factory_managed_private_endpoint" "df_managed_private" {
  name               = "df-managed"
  data_factory_id    = azurerm_data_factory.data_factory_bs.id
  target_resource_id = azurerm_storage_account.storage_account.id
  subresource_name   = "blob"
}

#Conexão Blob e ADF

resource "azurerm_data_factory_linked_service_azure_blob_storage" "df_linkedservice" {
  name              = "linked-service-bs"
  data_factory_id   = azurerm_data_factory.data_factory_bs.id
  connection_string = data.azurerm_storage_account.storage_account.primary_connection_string
}


# Gerencia um conjunto de dados de Blobs do Azure dentro de um Azure Data Factory.

resource "azurerm_data_factory_dataset_azure_blob" "df_dataset" {
  name                = "dataset-blob"
  data_factory_id     = azurerm_data_factory.data_factory_bs.id
  linked_service_name = azurerm_data_factory_linked_service_azure_blob_storage.df_linkedservice.name

  path     = "foo"
  filename = "bar.png"
}

#Gerencia um pipeline dentro de um Azure Data Factory.

resource "azurerm_data_factory_pipeline" "df_pipeline" {
  name            = "df-pipeline"
  data_factory_id = azurerm_data_factory.data_factory_bs.id
  
 variables = {
    "matricula_usuario" = "987654"
  }
  activities_json = <<JSON
[
    {
        "name": "Append variable1",
        "type": "AppendVariable",
        "dependsOn": [],
        "userProperties": [],
        "typeProperties": {
          "variableName": "bob",
          "value": "something"
        }
    }
]
  JSON
}