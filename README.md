Демо приложение, реализующее cookie based аутентификацию и авторизацию для сервиса кастомеров.

Чтобы мониторить метрики приложения, применим конфигмап для dashboard графаны и развернем Prometheus в namespace'е monitoring:

```
kubectl create namespace monitoring
helm install prom stable/prometheus-operator -f ./deploy/helm/monitoring/prometheus.yaml --atomic -n monitoring
```

Для мониторинга метрик БД установим postgres-exporter:

```
helm install postgre-metrics stable/prometheus-postgres-exporter -n monitoring
```

Создадим namespace для приложения и установим его в качестве текущего:

```
kubectl create namespace otus && kubectl config set-context --current --namespace=otus
```

Установим nginx ingress controller:

```
helm install nginx stable/nginx-ingress -f ./deploy/helm/nginx-ingress.yaml --atomic -n otus
```

Устанавливаем приложение:

````
make run
````

Убеждаемся, что все запущено:

```
$ kubectl get all

```

После запуска сервис доступен по адресу http://arch.homework.

Для запуска end-2-end тестов, используя newman:

```
newman run ./test/api.v1.postman_collection.json
```

Для удаления приложения:

```
make remove
```

Запускаем прометей:

```
kubectl port-forward -n monitoring service/prom-prometheus-operator-prometheus 9090
```