variable "resource_group_name" {
  type = string
  description = "Nome do Grupo de Recurso"
  default = "rg-vnet"
}


variable "location" {
  type = string
  description = "Localização do Grupo de Recursos"
  default = "Brazil South"
}

variable "admin_password" {
  description = "Senha do admin"
  type        = string
  default = "1ndr@Mins@1t123"
  sensitive   = true

}


