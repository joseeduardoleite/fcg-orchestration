# Remove RabbitMQ antigo
kubectl delete deployment rabbitmq
kubectl delete service rabbitmq

# Remove todas as APIs
$apis = @("users-api","catalog-api","payments-api","notifications-api")
foreach ($api in $apis) {
    kubectl delete deployment $api
    kubectl delete service $api
}
