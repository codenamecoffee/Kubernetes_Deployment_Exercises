#!/bin/bash

# === CONFIGURACIÓN INICIAL ===
STUDENTS_GROUPID="bff38521-c53d-4e9c-b347-4f66e88b10b9"  # Cambiar por el GroupId de tu grupo de estudiantes
ACR_NAME="acrk8sschoolof"          # Debe ser único globalmente
RESOURCE_GROUP="MVDSchoolof-2025-k8s-rg"                    # Cambiar por tu grupo de recursos
LOCATION="eastus"                         # O tu región preferida
IMAGE_NAME="movie-shop-api"
IMAGE_TAG="latest"
ACR_URL="${ACR_NAME}.azurecr.io"
SCOPE="/subscriptions/e75f4279-a56e-444b-81f3-cc089c8a47e0/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ContainerRegistry/registries/$ACR_NAME"

echo "==============================="
echo "Iniciando despliegue a ACR"
echo "==============================="

# === 1. Verificar si el ACR ya existe ===
echo "Verificando si el ACR '$ACR_NAME' ya existe..."
if az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" --only-show-errors &>/dev/null; then
    echo "ACR '$ACR_NAME' ya existe."
else
    echo "Creando ACR '$ACR_NAME' en '$LOCATION'..."
    az acr create \
      --name "$ACR_NAME" \
      --resource-group "$RESOURCE_GROUP" \
      --sku Basic \
      --location "$LOCATION" \
      --admin-enabled true \
      --only-show-errors
      
      # Assign role AcrPull to Students security group 
      az role assignment create \
      --assignee-object-id $STUDENTS_GROUPID \
      --assignee-principal-type Group \
      --role "AcrPull" \
      --scope $SCOPE

fi

# === 2. Verificar si ya estás logueado en ACR ===
echo "Verificando acceso a '$ACR_URL'..."
if docker system info | grep -q "$ACR_URL"; then
    echo "Ya estás logueado en Docker para $ACR_URL."
else
    echo "Realizando login en $ACR_URL..."
    az acr login --name "$ACR_NAME" --only-show-errors
fi

# === 3. Etiquetar la imagen local ===
echo "Etiquetando la imagen local '$IMAGE_NAME:$IMAGE_TAG' como '$ACR_URL/$IMAGE_NAME:$IMAGE_TAG'..."
docker tag "$IMAGE_NAME:$IMAGE_TAG" "$ACR_URL/$IMAGE_NAME:$IMAGE_TAG"

# === 4. Subir la imagen al ACR ===
# La imagen debe estar creada previamente en el docker local

echo "Subiendo la imagen a ACR..."
docker push "$ACR_URL/$IMAGE_NAME:$IMAGE_TAG"

echo "Imagen publicada exitosamente en: $ACR_URL/$IMAGE_NAME:$IMAGE_TAG"
