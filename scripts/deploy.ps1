# ===============================================
# Script de deploy automático para Kubernetes: José Eduardo Camilo Leite
# ===============================================

# Função para aguardar pod ficar pronto
function Wait-PodReady {
    param(
        [string]$podLabel,
        [int]$timeoutSeconds = 60
    )

    $elapsed = 0
    while ($elapsed -lt $timeoutSeconds) {
        $pod = kubectl get pods -l app=$podLabel -o json | ConvertFrom-Json
        if ($pod.items.Count -gt 0 -and $pod.items[0].status.containerStatuses[0].ready) {
            Write-Host "$podLabel pronto!"
            return
        }
        Start-Sleep -Seconds 2
        $elapsed += 2
    }
    Write-Warning "$podLabel não ficou pronto dentro de $timeoutSeconds segundos"
}

# ===============================================
# 1 Orquestração
# ===============================================
$orchestrationPath = "..\k8s"
Write-Host "Aplicando Secrets e ConfigMaps da orquestracao..."
kubectl apply -f "$orchestrationPath/secret.yaml"
kubectl apply -f "$orchestrationPath/configmap.yaml"

Write-Host "Aplicando RabbitMQ..."
kubectl apply -f "$orchestrationPath/rabbitmq.yaml"

# Espera o RabbitMQ ficar pronto
Wait-PodReady -podLabel "rabbitmq" -timeoutSeconds 60

Write-Host "Dando um tempo pro RabbitMQ estabilizar, fazer o que.. xD"
Start-Sleep -Seconds 15


# ===============================================
# 2 APIs
# ===============================================
$apis = @(
    "..\..\fcg-users-api\k8s",
    "..\..\fcg-catalog-api\k8s",
    "..\..\fcg-payments-api\k8s",
    "..\..\fcg-notifications-api\k8s"
)

foreach ($apiPath in $apis) {
    Write-Host "Aplicando recursos da API: $apiPath"

    # Secrets e ConfigMap da API
    kubectl apply -f "$apiPath/secret.yaml"
    kubectl apply -f "$apiPath/configmap.yaml"

    # Deployment e Service
    kubectl apply -f "$apiPath/deployment.yaml"
    kubectl apply -f "$apiPath/service.yaml"
}

# ===============================================
# 3 Verificar status final
# ===============================================
Write-Host "`nVerificando pods..."
kubectl get pods

Write-Host "`nVerificando services..."
kubectl get svc

Write-Host "`nDeploy concluido, meus caros!"
