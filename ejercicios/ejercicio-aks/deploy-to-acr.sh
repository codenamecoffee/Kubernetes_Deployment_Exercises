#!/bin/bash

# === CONFIGURACIÓN INICIAL ===
STUDENTS_GROUPID="bff38521-c53d-4e9c-b347-4f66e88b10b9"  # Cambiar por el GroupId de tu grupo de estudiantes
STUDENTS_ROLE="Reader"
ACR_NAME="acrk8sschoolof"
RESOURCE_GROUP="MVDSchoolof-2025-k8s-rg"
LOCATION="eastus"
IMAGE_NAME="movie-shop-api"
IMAGE_TAG="latest"
IMAGE_TAGV1="v1"
ACR_URL="${ACR_NAME}.azurecr.io"
SCOPE_RG="/subscriptions/e75f4279-a56e-444b-81f3-cc089c8a47e0/resourceGroups/$RESOURCE_GROUP"
SCOPE_ACR="$SCOPE_RG/providers/Microsoft.ContainerRegistry/registries/$ACR_NAME"

echo "==============================="
echo "Iniciando despliegue a ACR"
echo "==============================="

# === 0. Verificar si el Resource Group existe, y crearlo si no ===
echo "Verificando si el Resource Group '$RESOURCE_GROUP' existe..."
if az group show --name "$RESOURCE_GROUP" --output none 2>/dev/null; then
    echo "El Resource Group '$RESOURCE_GROUP' ya existe."
else
    echo "Creando Resource Group '$RESOURCE_GROUP' en '$LOCATION'..."
    az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none

    echo "Asignando rol $STUDENTS_ROLE al grupo de estudiantes en el Resource Group..."
     az role assignment create --assignee-object-id "$STUDENTS_GROUPID" --assignee-principal-type Group --role "$STUDENTS_ROLE" --scope "$SCOPE_RG"

fi

# === 1. Verificar si el ACR ya existe ===
echo "Verificando si el ACR '$ACR_NAME' ya existe..."
if az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" --only-show-errors &>/dev/null; then
    echo "ACR '$ACR_NAME' ya existe."
else
    echo "Creando ACR '$ACR_NAME' en '$LOCATION'..."
    az acr create --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" --sku Basic --location "$LOCATION" --admin-enabled true --only-show-errors

    echo "Asignando rol AcrPull al grupo de estudiantes..."
    az role assignment create       --assignee-object-id "$STUDENTS_GROUPID"       --assignee-principal-type Group       --role "AcrPull"       --scope "$SCOPE_ACR"
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
echo "Etiquetando la imagen local '$IMAGE_NAME:$IMAGE_TAG' como '$ACR_URL/$IMAGE_NAME:$IMAGE_TAGV1'..."
docker tag "$IMAGE_NAME:$IMAGE_TAG" "$ACR_URL/$IMAGE_NAME:$IMAGE_TAGV1"

# === 4. Subir las imagenes a ACR ===
echo "Subiendo la imagen latest a ACR..."
docker push "$ACR_URL/$IMAGE_NAME:$IMAGE_TAG"
echo "Imagen publicada exitosamente en: $ACR_URL/$IMAGE_NAME:$IMAGE_TAG"

echo "Subiendo la imagen v1 a ACR..."
docker push "$ACR_URL/$IMAGE_NAME:$IMAGE_TAGV1"
echo "Imagen publicada exitosamente en: $ACR_URL/$IMAGE_NAME:$IMAGE_TAGV1"

