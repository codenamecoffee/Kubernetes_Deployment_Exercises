#!/bin/bash

set -e

echo "=========================================="
echo "Instalación de entorno Kubernetes local"
echo "Componentes: kubectl + kind + clúster local"
echo "Requiere: Docker instalado y en funcionamiento"
echo "=========================================="

# === CONFIGURACIÓN DE VARIABLES ===

# Nombre del clúster Kind
CLUSTER_NAME="k8s-kind-clase"

# === 1. Instalar kubectl (si no está instalado) ===
if ! command -v kubectl >/dev/null 2>&1; then
  echo "Instalando kubectl..."
  curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
else
  echo "kubectl ya está instalado."
fi

# === 2. Instalar kind (si no está instalado) ===
if ! command -v kind >/dev/null 2>&1; then
  echo "Instalando kind..."
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64
  chmod +x ./kind
  sudo mv ./kind /usr/local/bin/kind
else
  echo "kind ya está instalado."
fi

# === 3. Crear clúster con kind ===
if kind get clusters | grep -q $CLUSTER_NAME; then
  echo "El clúster $CLUSTER_NAME ya existe."
else
  echo "Creando clúster $CLUSTER_NAME..."
  kind create cluster --name $CLUSTER_NAME
fi

# === 4. Verificar clúster ===
echo "Verificando que el clúster esté activo..."
kubectl cluster-info --context kind-$CLUSTER_NAME
kubectl get nodes

echo "=========================================="
echo "Entorno Kubernetes listo para usar."
echo "Usá kubectl para interactuar con el clúster."
echo "=========================================="
