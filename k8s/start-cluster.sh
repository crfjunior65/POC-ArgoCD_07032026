#!/bin/bash
set -e

# Configurações do seu fork
GITHUB_REPO="https://github.com/crfjunior65/POC-ArgoCD_07032026.git"
GITHUB_USER="crfjunior65"

echo "=== 🧹 Limpando ambiente anterior ==="
kind delete cluster --name kind || true

echo "=== 🏗️ Criando cluster Kind (Mapeando portas 80, 443, 8000) ==="
kind create cluster --config k8s/kind-config.yaml --name kind

echo "=== 🛠️ Instalando ArgoCD e Image Updater ==="
kubectl create namespace argocd || true
kubectl apply --server-side -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply --server-side -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/v0.12.2/manifests/install.yaml

echo "=== ⏳ Aguardando ArgoCD ficar pronto (Pode demorar uns 2-3 min) ==="
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Recuperar senha inicial do ArgoCD
ARGOCD_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "****************************************************"
echo " ArgoCD admin password: $ARGOCD_PWD"
echo "****************************************************"

echo "=== 🔑 Configurando Credenciais do Git (Necessário para Image Updater) ==="
if [ -z "$GITHUB_TOKEN" ]; then
    echo "⚠️  AVISO: A variável GITHUB_TOKEN não está definida!"
    echo "Por favor, digite seu Personal Access Token (PAT) do GitHub:"
    read -s GITHUB_TOKEN
    export GITHUB_TOKEN
fi

# Criar os segredos do ArgoCD com o seu token e repositório
# Usamos envsubst para preencher as variáveis nos arquivos YAML
echo "Aplicando credenciais do repositório..."
cat argocd/repo-credentials.yaml | \
  sed "s/\$YOUR_GITHUB_USERNAME/$GITHUB_USER/g" | \
  sed "s/\$YOUR_GITHUB_TOKEN/$GITHUB_TOKEN/g" | \
  kubectl apply -f -

echo "Aplicando credenciais do Image Updater..."
cat argocd/image-updater.secret.yaml | \
  sed "s/\$YOUR_GITHUB_TOKEN/$GITHUB_TOKEN/g" | \
  kubectl apply -f -

echo "=== 🚀 Iniciando o Deploy via GitOps (ArgoCD Application) ==="
kubectl apply -f argocd/app.yaml

echo "=== ✅ Setup Concluído! ==="
echo "Dicas úteis:"
echo "1. ArgoCD UI: http://localhost:8080 (se fizer port-forward)"
echo "2. Sua API (NodePort): http://localhost:30080"
echo "3. Kibana: http://localhost:5601 (se fizer port-forward)"
echo
echo "Comando para ver o status do deploy:"
echo "kubectl get pods -A"