# 🚀 Relatório Técnico: POC ArgoCD & GitOps (Fase 1)

Este documento detalha todas as implementações, correções e aprendizados realizados na primeira fase do projeto de modernização da infraestrutura local utilizando **Kubernetes (Kind)** e **ArgoCD**.

---

## 🏗️ 1. Visão Geral da Arquitetura
O objetivo desta fase foi estabelecer um ambiente de **Entrega Contínua (CD)** baseado no modelo **GitOps**.

*   **Single Source of Truth (SSOT):** O repositório Git é a única fonte de verdade.
*   **Reconciliação Automática:** O ArgoCD garante que o Kubernetes reflita exatamente o que está no Git.
*   **Automação de Imagens:** O ArgoCD Image Updater monitora o Docker Hub e atualiza o Git sozinho.

---

## 🛠️ 2. O que Implementamos e Corrigimos

### 🔹 Padronização de Nomenclatura
*   **Ação:** Renomeamos todos os recursos de `hello-api` para apenas `api`.
*   **Por que?** Simplicidade e clareza. Em projetos reais, nomes curtos e descritivos facilitam o uso de seletores e a leitura de logs.

### 🔹 Estrutura de Namespaces
*   **Ação:** Criamos a `api-namespace` e movemos todos os recursos para lá.
*   **Por que?** Isolamento. Em Kubernetes, as namespaces evitam conflitos de nomes e permitem aplicar políticas de segurança e limites de recursos de forma organizada.

### 🔹 Correção da API Python (O erro de driver)
*   **Problema:** A API dava erro `ImportError: no pq wrapper available`.
*   **Solução:** Alteramos o `requirements.txt` para `psycopg[binary]` e corrigimos o `Dockerfile`.
*   **Aprendizado:** Imagens Docker `slim` não possuem bibliotecas do sistema (como a `libpq` do Postgres). Usar a versão `binary` da biblioteca Python resolve o problema ao embutir esses drivers.

### 🔹 Estabilização da Stack ELK (Elasticsearch & Kibana)
*   **Problema:** Kibana em `CreateContainerConfigError` e falha de login.
*   **Solução:** 
    *   Criamos o `elasticsearch-secrets.yaml` com as chaves que o Kibana precisava.
    *   Alinhamos as senhas do **Init Container** do Kibana com o Segredo do cluster.
*   **Aprendizado:** O Kubernetes exige que todos os Segredos referenciados existam antes de subir o Pod.

---

## 📜 3. Guia de Comandos (O "Canivete Suíço")

Aqui estão os comandos que usamos e o que cada um faz:

### 🐋 Docker & Imagens
| Comando | Funcionalidade |
| :--- | :--- |
| `docker build -t user/repo:tag .` | Constrói uma imagem Docker a partir do `Dockerfile`. |
| `docker push user/repo:tag` | Envia a imagem para o Docker Hub (nuvem). |
| `docker login` | Autentica seu terminal na conta do Docker Hub. |

### ☸️ Kubernetes (Kubectl)
| Comando | Funcionalidade |
| :--- | :--- |
| `kubectl get pods -n api-namespace` | Lista todos os pods na namespace da aplicação. |
| `kubectl logs -f deployment/api -n api-namespace` | Acompanha os logs da API em tempo real. |
| `kubectl describe pod <nome-do-pod> -n api-namespace` | Mostra detalhes e erros de um pod específico. |
| `kubectl apply --server-side -f <arquivo>` | Aplica uma configuração ignorando limites de tamanho de anotação (importante para CRDs). |

### 🐙 Git & GitOps
| Comando | Funcionalidade |
| :--- | :--- |
| `git add . && git commit -m "msg"` | Salva suas mudanças localmente com uma mensagem explicativa. |
| `git push origin main` | Envia suas mudanças para o GitHub (Gatilho para o ArgoCD). |
| `watch kubectl get pods -A` | Monitora todos os pods do cluster, atualizando a cada 2 segundos. |

---

## 🚀 4. Próximos Passos (Fase 2)
Agora que a fundação está sólida e os serviços estão `Running`, estamos prontos para:
1.  **Explorar o Kibana:** Criar Dashboards e visualizar os logs da API.
2.  **Testar o Image Updater:** Fazer um novo push de imagem e ver o ArgoCD atualizar o código sozinho no GitHub.
3.  **Persistence Check:** Validar se os dados do Postgres sobrevivem ao restart do cluster.

---
> **Data:** 07 de Março de 2026
