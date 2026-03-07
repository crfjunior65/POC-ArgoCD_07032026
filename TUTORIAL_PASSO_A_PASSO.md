# 🎓 Tutorial Passo a Passo: GitOps com ArgoCD & Kubernetes (Fase 1)

Este guia prático ensina como configurar do zero o ambiente de Entrega Contínua (GitOps) que construímos. Siga cada etapa para entender o fluxo completo de um Engenheiro SRE/DevOps.

---

## 🏗️ Passo 1: Preparação do Repositório (Fork)
Antes de tudo, o código precisa estar na sua conta do GitHub para que você tenha permissão de escrita.
1.  Faça o **Fork** do repositório original para sua conta.
2.  No arquivo `argocd/app.yaml`, altere o campo `repoURL` para a URL do seu fork.
    *   **Comando:** `git remote -v` (Para validar qual o seu repositório remoto atual).

---

## 🐋 Passo 2: Construção da Imagem Docker (API)
A API precisa dos drivers corretos para falar com o banco de dados.
1.  No arquivo `api/requirements.txt`, use `psycopg[binary]`.
2.  No `api/Dockerfile`, instale a biblioteca `libpq5` para garantir que o Linux do contêiner entenda o Postgres.
3.  **Comandos de Build e Push:**
    *   `cd api` (Entra na pasta da aplicação).
    *   `docker build -t crfjunior65/poc-gitops:v3.0.2 .` (Constrói a imagem com uma versão/tag específica).
    *   `docker push crfjunior65/poc-gitops:v3.0.2` (Envia a imagem pronta para o Docker Hub).

---

## 🕹️ Passo 3: Provisionamento do Cluster (Kind)
Criamos um cluster local dentro do Docker para simular a nuvem.
1.  Configure o arquivo `k8s/kind-config.yaml` com o mapeamento de portas (80, 443, 8000, 30080).
2.  **Comando para subir o cluster:**
    *   `./k8s/start-cluster.sh` (Este script automatiza a criação do cluster e a instalação do ArgoCD).

---

## 🐙 Passo 4: Configuração do GitOps (ArgoCD)
O ArgoCD será o "vigia" que olha o seu GitHub e atualiza o Kubernetes.
1.  **Instalação:** O script usa `kubectl apply --server-side` para instalar o ArgoCD sem erros de tamanho de arquivo.
2.  **Credenciais:** Você precisa gerar um **Personal Access Token (PAT)** no GitHub e fornecer ao script quando solicitado.
3.  **Comando para ver a senha do ArgoCD:**
    *   `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d` (Gera a senha para você logar no painel web em localhost:8080).

---

## 📂 Passo 5: Organização por Namespaces
Dividimos o cluster em "pastas" lógicas para não misturar as coisas.
1.  Criamos o arquivo `k8s/manifests/namespace.yaml`.
2.  No `k8s/manifests/kustomization.yaml`, definimos `namespace: api-namespace`. Isso move automaticamente a API e o Postgres para lá.
3.  **Comando de validação:**
    *   `kubectl get pods -n api-namespace` (Mostra apenas o que pertence à sua aplicação).

---

## 📊 Passo 6: Estabilização da Observabilidade (ELK)
Logs e Monitoramento com Elasticsearch e Kibana.
1.  **Segredos:** Criamos o `elasticsearch-secrets.yaml` com as senhas. Sem isso, o Kibana dá erro de configuração.
2.  **Alinhamento:** Garantimos que a senha no `kibana-deployment.yaml` seja a mesma do segredo (`elastic123`).
3.  **Comando de logs:**
    *   `kubectl logs -f deployment/kibana -n api-namespace` (Para ver o Kibana "acordando").

---

## 📜 Tabela de Comandos e Funcionalidades

| Comando | O que ele faz? | Por que usar? |
| :--- | :--- | :--- |
| `docker login` | Autentica no Docker Hub. | Sem isso, você não tem permissão para dar `push`. |
| `kubectl apply --server-side` | Aplica arquivos YAML pesados. | Evita o erro de "Too long" em objetos grandes como o ArgoCD. |
| `kubectl get pods -A` | Lista todos os pods de todos os lugares. | Para ter uma visão geral da saúde do cluster. |
| `kubectl logs -l app=api` | Mostra os logs da aplicação pelo label. | Mais rápido que digitar o nome completo do pod. |
| `git push origin main` | Envia o código para o GitHub. | É o gatilho que faz o ArgoCD atualizar o Kubernetes sozinho. |
| `watch kubectl get pods` | Atualiza a lista de pods a cada 2s. | Para acompanhar o processo de subir/descer pods sem digitar o comando toda hora. |

---

## 💡 Dica de Ouro do DevOps Senior:
Sempre que você mudar um arquivo `.yaml` ou o código da API, o fluxo é:
`Mudar Local -> Commit/Push GitHub -> Aguardar ArgoCD sincronizar`. 

**O GitOps elimina a necessidade de você rodar comandos manuais no Kubernetes!**
---
