# Ejercicio: Desplegar una aplicación desde ACR en AKS (Demo guiada)

Este ejercicio está pensado para ser conducido por el instructor y seguido por los estudiantes.
El objetivo es:

- Ver cómo se crea un clúster AKS y se conecta con ACR
- Desplegar una aplicación real desde ACR
- Exponerla con un Service LoadBalancer
- Observar el balanceo entre pods y otras características avanzadas

---

## 1. Clonar el repositorio del curso

```bash
git clone git@github.com:codenamecoffee/Kubernetes_Deployment_Exercises.git
cd <repo-name>/ejercicios/ejercicio-aks
```
---

## 2. Ejecutar los scripts de preparación

Ejecutar desde su terminal:

```bash
deploy-to-acr.sh
create-aks-cluster.sh
```

Esto realiza:

- La creación del registro ACR (si no existía)
- La construcción y publicación de la imagen Docker
- La creación del clúster AKS con conexión al ACR

---

## 3. Obtener acceso al clúster AKS

Para conectarte al clúster y trabajar con `kubectl`, usá:

```bash
az login --tenant endava.onmicrosoft.com
az aks get-credentials --resource-group MVDSchoolof-2025-k8s-rg --name k8s-aks-clase --overwrite-existing
```

Esto configura el contexto de `kubectl` para apuntar al clúster AKS.

Verificá el contexto actual:

```bash
kubectl config current-context
```

Verificá que el clúster esté accesible:

```bash
kubectl get nodes
```

---

## 4. Alternar entre contextos AKS y Kind (si ya trabajaste en local)

Listar todos los contextos disponibles:

```bash
kubectl config get-contexts
```

Cambiar al clúster AKS:

```bash
kubectl config use-context k8s-aks-clase
```

Volver al clúster Kind (si existe):

```bash
kubectl config use-context kind-k8s-kind-clase
```

---

## 5. Aplicar deployment de la version v1 y service en AKS

```bash
kubectl apply -f deployment-v1.yaml
kubectl apply -f service.yaml
```

Verificar:

```bash
kubectl get pods
atus.phase,RESTARTS:.status.containerStatuses[*].restartCount,AGE:.metadata.creationTimestamp,IMAGE:.spec.containers[*].image"
kubectl get svc movie-shop-service
```

Esperar una IP pública en `EXTERNAL-IP`.

---

## 6. Probar la aplicación

Una vez asignada la IP pública:

```bash
curl http://movie-shop.$(kubectl get svc movie-shop-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}').nip.io/docs
```

También podés abrir la URL en el navegador:

http://movie-shop.<EXTERNAL-IP>.nip.io/docs
kubectl get pods -o=custom-columns="NAME:.metadata.name,READY:.status.containerStatuses[*].ready,STATUS:.st
Obtener external Ip del Load Balancer en la terminal

```bash
kubectl get svc movie-shop-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

---

## 7. Observar balanceo de carga entre pods

Monitorear actualización de los pods:

En una terminal ejecutar el siguiente comando:

```bash
kubectl get pods -l app=movie-shop
watch -n1 kubectl get pods -o=custom-columns="NAME:.metadata.name,READY:.status.containerStatuses[*].ready,STATUS:.status.phase,RESTARTS:.status.containerStatuses[*].restartCount,AGE:.metadata.creationTimestamp,IMAGE:.spec.containers[*].image"
```

Escalar el `Deployment` para crear múltiples réplicas del pod:

```bash
kubectl scale deployment movie-shop --replicas=3
```

### Observar los logs en tiempo real (desde otra terminal)

```bash
kubectl logs -l app=movie-shop --prefix=true --timestamps -f
```
o
```bash
kubectl logs pod/<nombre-del-pod> --prefix=true --timestamps -f
```


Esto permite ver qué pod está respondiendo a cada solicitud.  
Si el balanceo está funcionando correctamente, verás que los logs provienen de **pods distintos**, lo que indica que el `Service` está distribuyendo el tráfico entre réplicas.

### Generar tráfico al servicio (desde una terminal)

Este comando hace una solicitud HTTP cada segundo al endpoint `/docs` a través de la IP pública del `Service`:

```bash
watch -n1 curl http://movie-shop.$(kubectl get svc movie-shop-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}').nip.io/docs
```

---

## 8. Prueba adicional: actualizar la aplicación a la version latest

El instructor tiene permisos:
- Crear una nueva versión de la imagen
- Subirla al ACR con un nuevo tag (`latest`)

Desplegar la version latest y verificar que los pods antiguos version v1 se terminan y se crean nuevos version latest.

```bash
kubectl apply -f deployment-latest.yaml  ; watch -n1 kubectl get pods -o=custom-columns="NAME:.metadata.name,READY:.status.containerStatuses[*].ready,STATUS:.status.phase,RESTARTS:.status.containerStatuses[*].restartCount,AGE:.metadata.creationTimestamp,IMAGE:.spec.containers[*].image"
```

---

## 9. Escalar el clúster AKS (scale out)

Para mostrar que el clúster AKS puede ampliarse dinámicamente, realizaremos un **scale out**, es decir, aumentaremos la cantidad de nodos disponibles en el nodo pool predeterminado.

### Comando para escalar de 1 a 2 nodos:

```bash
az aks scale --resource-group MVDSchoolof-2025-k8s-rg --name k8s-clase --node-count 2
```

### Verificar los nuevos nodos:

```bash
kubectl get nodes -o wide
```

Esto mostrará una lista de nodos. Deberías ver 2 nodos con estado `Ready` en poco tiempo (el aprovisionamiento puede tardar algunos minutos).

Este ejercicio demuestra cómo Kubernetes puede expandir su capacidad física para manejar más cargas de trabajo de forma declarativa y dinámica.

---

## 10. Permisos para estudiantes

Los estudiantes tendrán acceso limitado al clúster AKS:

- Solo podrán consultar recursos (`get`, `list`)
- No podrán crear deployments ni servicios
- Solo ejecutarán comandos de observación y diagnóstico

Esto se logra configurando un `RoleBinding` con permisos de solo lectura sobre el namespace donde se despliega la app.

---

Fin del ejercicio.
