# Techday Demo

![BlueGreen (1)](https://user-images.githubusercontent.com/44185718/199161438-1b0144cc-9cdc-4b95-8276-e7ca8a07d416.png)


DESCRIÇÃO

O BlueGreen Demo Project foi desenhado para apresentar um modelo simples de rapido deploy utilizando IaC (Infraestrutura como código em português) para um sistema que suporte deployments utilizando o modelo blue/green sem oferencer downtime aos usuarios
.Este projeto foi desenhado para ser executado em uma Azure subscription utilizando uma conta que tenha permissões para provisionar os recursos enumerados no codigo Terraform.

OBJETIVO

O objetivo desse demo é demonstrar a facilidade de deploy de infraestrutura com multiplos clusters kubernetes, altamente disponível, escalável e ainda oferecendo a possibilidade de realizar upgrades nos componentes criticos de infraestura sem que o usuario experimente downtime. 

O exercicio toca nos seguintes pontos: Infraestrutura como código utilizado terraform, Kubernetes para orquestração de containers, cert-manager e let's encrypt para geração de certificados SSL para o ingress da aplicação e helm-charts e seu deploy utilizando terraform. 


Este demo é composto dos seguintes componentes:
1. Dois Kubernetes Clusters Localizados na região east us (pode ser modificado para a zona de preferência)
2. Um Azure Traffic manager para distribuir o traffico entre os dois clusters diferentes
3. Cert-Manager Helm-chart para realizar o provisionamento de certificados SSL que serão utilizados pelos ingresses da aplicação demo.
4. Ingress Controller Nginx helm-chart.
5. O My site demo app helm-chart. O mysite é uma aplicação flask simples para demonstração dos exercicios propostos neste documento. 


REQUISITOS

Para facilitar a etapa de requisitos é recomendado utilizar brew para usuarios de Mac OS, para usuarios linux, utilizar o sistema de gerenciamento de pacotes compativel com a distribuição que utilize, e Chocolatey para usuarios do sistema Microsoft Windows. 

Também é recomendado a utilização de uma conta Microsoft Azure gratuita se ainda elegível. Caso haja preferência por um outro provedor de serviços na nuvem como AWS e google o código Terraform terá de ser convertido manualmente pelo usuario.

* AZ CLI Instalado    - https://learn.microsoft.com/en-us/cli/azure/install-azure-cli
* Terraform Instalado - https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
* Subscrição Azure    - https://azure.microsoft.com/pt-br/free/

** Os seguintes são apenas caso exista o interesse em realizar testes e troubleshooting nos clusters kubernetes

Kubectl - https://kubernetes.io/docs/tasks/tools/
Helm    - https://helm.sh/docs/intro/install/


COMO UTILIZAR

Uma vez tendo os requisitos instalados e disponíveis, realizar a execução dos seguintes comandos no diretório bluegreendemo-tf:

** Antes de iniciar é recomendado que as variaveis "env" localizada no arquivo variables.tf sejam reajustadas de acordo com a sua preferencia, a mudança de nome é necessária pois se mais de um ambiente for provisionado com a mesma nomenclatura, haverá um conflito de nome. 

1 - Utilize o seguinte comando para conectar a subscrição Azure desejada para realizar deploy dos componentes utilizando infraestrutura como código.
az login

2 - Uma vez conectado a subscrição pela linha de comando utilize o seguinte comando para iniciar o diretório contendo os arquivos de configuração Terraform
terraform init

3 - Execute o comando para visualizar o plano terraform que irá demonstrar todos os componentes que serão instalados durante a execução
terraform plan

4 - Uma vez confirmado que não existem erros 

EXERCICIOS PROPOSTOS

1. Os usuarios são encorajados a realizar simulações de atualizações completas das versões dos cluster kubernetes enquando o trafego é completamente divergido para o cluster que não esta sendo alterado e posteriormente ter o segundo cluster atualizado enquanto o trafego esta completamente divergido para o primeiro e finalmente quando os dois clusters estão atualizados ter trafego divergido entre ambos. 

2. Os exercicios também podem ser expandidos de maneira a ter o segundo cluster posicionado em uma região diferente a fim de realizar um balanceamento de trafego de acordo com a região mais indicada para o usuario A ou B. 

3. Realizar exercicios de upgrade dos componentes que são instalados através de helm-charts ou adicionar novos helm-charts e, consequentemente, novas ferramentas ou aplicações aos clusters. 

