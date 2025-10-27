# Ejercicio: Desplegar una aplicación desde ACR usando Kind

Este ejercicio guía paso a paso para:

- Crear un clúster local con Kind
- Cargar una imagen Docker desde Azure Container Registry (ACR)
- Desplegar la aplicación en Kubernetes
- Exponerla localmente para pruebas

---

## 1. Clonar el repositorio del curso

```bash
git clone git@github.com:codenamecoffee/Kubernetes_Deployment_Exercises.git
cd <repo-name>/ejercicios/ejercicio-kind
```

---

## 2. Crear y configurar el clúster local con Kind

Ejecutar el script de instalación:

```bash
./setup-kind-cluster.sh
```

Este script:

- Instala `kubectl` y `kind` si no están presentes
- Crea un clúster llamado `k8s-kind-clase`
- Configura el contexto `kind-k8s-kind-clase` como activo

---

## 3. Iniciar sesión en Azure y loguearse a ACR

Primero iniciar sesión:

```bash
az login --tenant endava.onmicrosoft.com
```

Luego loguearse a ACR:

```bash
az acr login --name acrk8sschoolof
```

---

## 4. Cargar la imagen de ACR al clúster Kind

```bash
docker pull acrk8sschoolof.azurecr.io/movie-shop-api:latest

kind load docker-image acrk8sschoolof.azurecr.io/movie-shop-api:latest --name k8s-kind-clase
```

### ¿Por qué se usan estos dos comandos?

Kind ejecuta los nodos del clúster como contenedores Docker. Estos nodos no tienen acceso automático a la sesión de Docker ni pueden autenticarse contra registros privados como ACR.

Por eso, primero se baja la imagen en el entorno Docker local (`docker pull`), y luego se "inyecta" esa imagen dentro del clúster usando `kind load`. Esto garantiza que los pods puedan usarla sin necesidad de hacer `imagePull` desde adentro del clúster.

---

## 5. Desplegar la aplicación

Aplicar el archivo de manifiesto `deployment.yaml`:

```bash
kubectl apply -f deployment.yaml
```

El `Deployment` usa la imagen cargada anteriormente.

---

## 6. Verificar que el pod esté corriendo

```bash
kubectl get pods
kubectl logs -l app=movie-shop --prefix=true --timestamps
```

---

## 7. Exponer la aplicación con port-forward

```bash
kubectl port-forward deployment/movie-shop 8080:8000 &
```

Esto permite acceder a la aplicación desde el navegador local a través del puerto 8080.

---

## 8. Probar la aplicación

Desde la misma terminal:

```bash
curl http://localhost:8080/docs
```

---

## 9. Pruebas para entender cómo Kubernetes mantiene el estado deseado

Estas pruebas están diseñadas para reforzar los conceptos clave de Kubernetes: su naturaleza declarativa, su modelo de reconciliación, y su capacidad de autocuración.

---

### Ver qué pod responde a una solicitud

```bash
kubectl get pods -l app=movie-shop
kubectl logs -f -l app=movie-shop --prefix=true --timestamps
```

Luego, en otra terminal:

```bash
curl http://localhost:8080/docs
```

Verificá en los logs qué pod respondió la solicitud.

---

### Demostrar autocuración (self-healing)

```bash
kubectl get pods -l app=movie-shop -w
```

En otra terminal, eliminá uno de los pods:

```bash
kubectl delete pod <nombre-del-pod>
```

Kubernetes detecta que falta una réplica y crea automáticamente una nueva. Lo podés observar en tiempo real gracias al flag `-w` (watch).

---

### Escalar el despliegue

```bash
kubectl scale deployment movie-shop --replicas=3
```

Verificá que ahora haya tres pods en total (se agrega uno pues ya había dos del deployment apply anterior):

```bash
kubectl get pods -l app=movie-shop
```

---

### Ver el manifiesto activo del deployment

```bash
kubectl get deployment movie-shop -o yaml
```

Esto permite ver la configuración completa que Kubernetes está usando internamente.

---

### Eliminar el deployment y confirmar limpieza

```bash
kubectl delete deployment movie-shop
kubectl get pods
```

Esto ilustra cómo Kubernetes mantiene el estado deseado: si no hay Deployment, tampoco hay pods asociados.

---

# Añadir la sección de eliminación del clúster Kind al final del archivo markdown existente

texto_remover_cluster = """
---

## 10. Remover un clúster Kind

Una vez finalizado el ejercicio, podés limpiar tu entorno local eliminando el clúster Kind creado.

```bash
kind get clusters
kind delete cluster --name k8s-kind-clase
kubectl config delete-context kind-k8s-kind-clase
```

Fin del ejercicio.
