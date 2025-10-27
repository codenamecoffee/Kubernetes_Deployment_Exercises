#!/bin/bash

# =============================================================
# Script para crear un clúster de Kubernetes en Azure (AKS)
# Propósito: Demostración práctica para clase de DevOps
# =============================================================

# === CONFIGURACIÓN DE VARIABLES ===

# Nombre del grupo de recursos donde se creará el clúster
RESOURCE_GROUP="MVDSchoolof-2025-k8s-rg"

# Nombre del clúster AKS
CLUSTER_NAME="k8s-aks-clase"

# Nombre del Azure Container Registry (ACR) ya creado
ACR_NAME="acrk8sschoolof"

# Región de Azure donde se desplegará el clúster
LOCATION="eastus"

# Tipo de VM para cada nodo del clúster (2 vCPU, 4 GB RAM)
NODE_SIZE="Standard_B2s"

# Número de nodos en el pool inicial
NODE_COUNT=1

# ID del grupo de estudiantes (Microsoft Entra ID)
STUDENTS_GROUPID="bff38521-c53d-4e9c-b347-4f66e88b10b9"

# Subscripción y scope del AKS
SUBSCRIPTION_ID="e75f4279-a56e-444b-81f3-cc089c8a47e0"
SCOPE_AKS="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ContainerService/managedClusters/$CLUSTER_NAME"

# === CREACIÓN DEL CLÚSTER AKS ===

echo "Creando clúster AKS: $CLUSTER_NAME en $LOCATION..."

az aks create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CLUSTER_NAME" \
  --node-count "$NODE_COUNT" \
  --node-vm-size "$NODE_SIZE" \
  --enable-managed-identity \
  --generate-ssh-keys \
  --attach-acr "$ACR_NAME" \
  --location "$LOCATION"

# === ASIGNAR PERMISO DE ACCESO A LOS ESTUDIANTES PARA KUBECTL ===

echo "Asignando rol AKS Cluster User Role al grupo de estudiantes..."

az role assignment create \
  --assignee-object-id "$STUDENTS_GROUPID" \
  --assignee-principal-type Group \
  --role "Azure Kubernetes Service Cluster User Role" \
  --scope "$SCOPE_AKS"

# === CONFIGURACIÓN DE KUBECTL ===

echo "Configurando acceso con kubectl..."

az aks get-credentials \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CLUSTER_NAME" \
  --overwrite-existing

# === VALIDACIÓN FINAL ===

echo "Verificando estado del clúster..."
kubectl get nodes

# === APLICAR ROLES DE KUBERNETES PARA LOS ESTUDIANTES ===

echo "Aplicando Role y RoleBinding dentro del clúster AKS..."

# ------------------------------------------------------------
# Eliminamos "aks-cluster-admin-binding" porque otorgaba
# permisos de cluster-admin a todos los usuarios autenticados
# como "clusterAdmin" o "clusterUser", incluyendo estudiantes.
#
# Esto rompía el control por namespace y les daba acceso total.
# ------------------------------------------------------------
kubectl delete clusterrolebinding aks-cluster-admin-binding

kubectl apply -f role-student-deployer.yaml
kubectl apply -f rolebinding-student.yaml

echo "Verificando que Role y RoleBinding fueron creados correctamente..."

echo "Roles disponibles en el namespace 'default':"
kubectl get role -n default

echo "RoleBindings disponibles en el namespace 'default':"
kubectl get rolebinding -n default

echo "Configuración de RBAC aplicada correctamente para los estudiantes."
