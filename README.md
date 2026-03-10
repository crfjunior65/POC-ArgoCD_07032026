# ArgoCD GitOps/Image Updaters & Observability POC

![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![ArgoCD](https://img.shields.io/badge/argocd-%23ef7b4d.svg?style=for-the-badge&logo=argo&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![Flask](https://img.shields.io/badge/flask-%23000.svg?style=for-the-badge&logo=flask&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Elasticsearch](https://img.shields.io/badge/Elasticsearch-005571?style=for-the-badge&logo=elasticsearch&logoColor=white)
![Kibana](https://img.shields.io/badge/Kibana-005571?style=for-the-badge&logo=kibana&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)

Este projeto é uma Prova de Conceito (POC) que demonstra a implementação de uma arquitetura moderna de entrega contínua (GitOps) e observabilidade, utilizando **ArgoCD**, **Kubernetes (Kind)** e o **Stack ELK**.

A aplicação consiste em uma API Flask integrada a um banco de dados PostgreSQL, com monitoramento centralizado e automação de deploy via imagem.

---

## 🏗️ Arquitetura e Stack Tecnológica

O ecossistema é composto pelas seguintes tecnologias:

*   **Orquestração:** **Kubernetes** (via **Kind** para ambiente local).
*   **GitOps & CD:** **ArgoCD** para sincronização de manifestos e **ArgoCD Image Updater** para automação de tags.
*   **Observabilidade (ELK):** 
    *   **Elasticsearch:** Armazenamento de logs.
    *   **Filebeat:** Coleta de logs dos pods no K8s.
    *   **Kibana:** Visualização e análise de dados.
*   **Backend:** **Python Flask** com suporte a persistência.
*   **Database:** **PostgreSQL**.
*   **Métricas:** **Kube-state-metrics**.

---

## 🚀 Como Executar

### Pré-requisitos
*   [Docker](https://www.docker.com/)
*   [Kind](https://kind.sigs.k8s.io/)
*   [Kubectl](https://kubernetes.io/docs/tasks/tools/)

### 1. Provisionamento do Cluster
O projeto inclui um script de automação para subir todo o ambiente:

```bash
chmod +x k8s/start-cluster.sh
./k8s/start-cluster.sh
```

Este script irá:
1. Criar o cluster Kind baseado no `k8s/kind-config.yaml`.
2. Instalar o ArgoCD e o Image Updater.
3. Fornecer a senha inicial do administrador do ArgoCD.

### 2. Implantação da Aplicação (GitOps)
Aplique o manifesto da aplicação ArgoCD para iniciar a sincronização:

```bash
kubectl apply -f argocd/app.yaml
```

### 3. Acesso aos Serviços
Para acessar os serviços localmente, utilize o port-forward:

*   **ArgoCD UI:** `kubectl port-forward svc/argocd-server -n argocd 8080:443`
*   **API:** `kubectl port-forward svc/api-service 8000:8000`
*   **Kibana:** `kubectl port-forward svc/kibana-deployment 5601:5601`

---

## 🛠️ Detalhes da API

A API Flask possui os seguintes endpoints principais:

| Método | Endpoint | Descrição |
| :--- | :--- | :--- |
| `GET` | `/` | Health check simples / Boas-vindas. |
| `GET` | `/health` | Status da aplicação e conexão com o banco. |
| `POST` | `/clients` | Cadastro de novos clientes. |
| `GET` | `/clients` | Listagem de clientes cadastrados. |

---

## 🔄 Fluxo de Atualização (Image Updater)

O projeto está configurado para utilizar o **ArgoCD Image Updater**. Quando uma nova imagem for enviada ao Docker Hub seguindo o padrão de regex configurado no `argocd/app.yaml`, o ArgoCD detectará a mudança e atualizará o cluster automaticamente via commit no repositório Git (estratégia `write-back`).

---

## 📊 Observabilidade

Os logs de todos os pods são coletados automaticamente pelo **Filebeat** e enviados ao **Elasticsearch**. 
1. Acesse o Kibana em `localhost:5601`.
2. Crie um *Index Pattern* (ex: `filebeat-*`).
3. Explore os logs em tempo real na aba *Discover*.

---

## 📁 Estrutura do Repositório

```text
.
├── api/                # Código fonte da API Python e Dockerfile
├── argocd/             # Manifestos de App e segredos do ArgoCD
├── k8s/
│   ├── manifests/      # Deployments, Services e ConfigMaps (Kustomize)
│   ├── kind-config.yaml# Configuração do cluster local
│   └── start-cluster.sh# Script de setup completo
└── docker-compose.yaml # Setup para desenvolvimento local sem K8s
```

---
> **Disclaimer:** Este projeto é uma POC voltada para fins educacionais e de demonstração técnica de fluxos DevOps.
