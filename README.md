# Implementação de Azure Data Factory em Ambiente Privado

# Requisitos para iniciar a infraestrutura
Instalação do Terraform, Visual Studio Code e Azure CLI em máquina
Conta ativa na Azure para a criação de recursos
Configurar credenciais com Azure CLI para efetuar login na Azure utilizando "az login"

# Como inicializar a infraestrutura.
Executar seguintes comandos: 
Terraform init: Iniciar o terraform
Terraform validate: Verifica se o código está escrito corretamente
Terraform plan: Inicia um plano de execução, mostrando os recursos que serão criados
Terraform apply: Inicia o provisionamento dos recursos, após a confirmação com "yes"
Terraform destroy: Mostra em tela os recursos que serão destruidos, após a confirmação com "yes" é feito o processo de exclusão

# Verificar a configuração dos componentes.
Para a verificação da criação de um grupo de recursos, por exemplo, pode ser feito com o comando "terraform show" ou através do Portal da Azure na opção "grupo de recursos" ou "maquinas virtuais" 