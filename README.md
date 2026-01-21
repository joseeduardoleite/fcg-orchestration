# FiapCloudGames Orchestration

Este repositório é responsável pela **orquestração de toda a infraestrutura** do projeto FiapCloudGames utilizando **Docker** e **Kubernetes**.

Aqui são definidos:

- RabbitMQ (mensageria entre microserviços)
- Secrets e ConfigMaps
- Deployments e Services das APIs
- Script de automação de deploy

---

## 🧱 Arquitetura

O projeto é composto pelos seguintes microserviços:

- **Users API** – gerenciamento de usuários e autenticação
- **Catalog API** – catálogo de jogos
- **Payments API** – processamento de pagamentos e criação de contas
- **Notifications API** – envio de notificações (simulação de e-mail)
- **RabbitMQ** – broker de mensagens (eventos assíncronos com MassTransit)

Comunicação:

- Sincrona: HTTP (REST)
- Assíncrona: Eventos via RabbitMQ (ex: `UserCreatedEvent`, `PaymentApprovedEvent` e dentre outros)

---

## 📦 Tecnologias

- Docker
- Kubernetes
- RabbitMQ
- MassTransit
- .NET 8
- PowerShell (automação de deploy)

---

## 📁 Estrutura

```text
fcg-orchestration
│
├── k8s
│   ├── rabbitmq.yaml
│   ├── secret.yaml
│   └── configmap.yaml
│
├── scripts
│   ├── deploy.ps1
|   └── stop.ps1
│
└── README.md
```

Cada microserviço também possui sua própria pasta ``k8s`` em seus respectivos repositórios com:

- ``deployment.yaml``
- ``service.yaml``
- ``secret.yaml``
- ``configmap.yaml``

## 🚀 Subindo tudo do zero

### Build das imagens Docker

Em cada repositório de API:

```bash
docker build -t fcg-users-api .
docker build -t fcg-catalog-api .
docker build -t fcg-payments-api .
docker build -t fcg-notifications-api .
```

### Subir a infraestrutura no Kubernetes

No repositório fcg-orchestration, execute:

```shell
cd scripts
.\deploy.ps1
```

O script realiza:

- Criação de Secrets e ConfigMaps
- Deploy do RabbitMQ
- Aguarda RabbitMQ ficar pronto
- Deploy de todas as APIs
- Criação dos Services
- Verificação final dos pods e serviços

Exemplos:
- Swagger Users: http://localhost:5000/swagger
- Swagger Catalog: http://localhost:5001/swagger
- RabbitMQ: http://localhost:15672 (guest / guest)

## 📬 Mensageria

Eventos publicados no RabbitMQ:

- UserCreatedEvent
  - Consumido por:
    - Notifications → envia e-mail de boas-vindas
    - Payments → cria conta do usuário
- PaymentApprovedEvent
- PaymentRejectedEvent

Cada microserviço possui sua própria fila, garantindo fan-out (broadcast de eventos) e independência entre consumidores.

## 🛠 Observações Importantes

- Todas as configurações sensíveis estão em Secrets
- URLs, filas e hosts estão em ConfigMaps
- As APIs utilizam MassTransit com retry exponencial
- RabbitMQ é inicializado antes das APIs para evitar falhas de conexão
- O script aguarda o broker ficar pronto antes de subir os serviços

## 🔄 Rebuild completo (reset geral)

Caso precise zerar tudo:
```bash
kubectl delete all --all
kubectl delete configmap --all
kubectl delete secret --all
```

Depois:
```shell
.\deploy.ps1
```
## 🎯 Objetivo do Projeto

Demonstrar na prática:

- Arquitetura de microserviços
- Comunicação assíncrona com eventos
- Orquestração com Kubernetes
- Containers com Docker
- Observabilidade básica via logs
- Padrões modernos de integração (.NET + MassTransit + RabbitMQ)