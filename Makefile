.PHONY: prepare
prepare:
	#kubectl create namespace monitoring
	helm install prom stable/prometheus-operator -f ./deploy/helm/monitoring/prometheus.yaml --atomic -n monitoring
	helm install postgre-metrics stable/prometheus-postgres-exporter -n monitoring
	#kubectl create namespace otus && kubectl config set-context --current --namespace=otus
	helm install nginx stable/nginx-ingress -f ./deploy/helm/nginx-ingress.yaml --atomic -n otus

.PHONY: run
run:
	helm install auth-service ./deploy/helm/authservice -n otus
	helm install customer-service ./deploy/helm/customerservice -n otus

.PHONY: remove
remove:
	helm uninstall customer-service -n otus
	helm uninstall auth-service -n otus