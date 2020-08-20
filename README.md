Демо приложение, реализующее cookie based аутентификацию и авторизацию для сервиса кастомеров.

#### Архитектура решения

##### Регистрация

![](README.assets/registration.png)

##### Логин

![](README.assets/signin.png)

##### Чтение, обновление данных кастомера

![](README.assets/auth.png)


#### Установка приложения в Kubernetes

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
NAME                                                       READY   STATUS    RESTARTS   AGE
pod/auth-service-6f978bc96c-2qw47                          1/1     Running   2          63s
pod/auth-service-6f978bc96c-45rzk                          1/1     Running   2          63s
pod/auth-service-6f978bc96c-n2v4n                          1/1     Running   2          63s
pod/auth-service-postgresql-0                              2/2     Running   0          63s
pod/auth-service-redis-master-0                            2/2     Running   0          63s
pod/auth-service-redis-slave-0                             2/2     Running   0          63s
pod/auth-service-redis-slave-1                             2/2     Running   0          22s
pod/customer-service-7cdb99857d-pvwxt                      1/1     Running   2          93m
pod/customer-service-7cdb99857d-s48sp                      1/1     Running   2          93m
pod/customer-service-7cdb99857d-xk27c                      1/1     Running   2          93m
pod/customer-service-postgresql-0                          2/2     Running   0          93m
pod/nginx-nginx-ingress-controller-xtz8h                   1/1     Running   0          95m
pod/nginx-nginx-ingress-default-backend-679f548db6-wdmvc   1/1     Running   0          95m

NAME                                             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
service/auth-service                             NodePort    10.96.184.131   <none>        9000:31979/TCP               63s
service/auth-service-postgresql                  ClusterIP   10.111.131.93   <none>        5432/TCP                     63s
service/auth-service-postgresql-headless         ClusterIP   None            <none>        5432/TCP                     63s
service/auth-service-postgresql-metrics          NodePort    10.97.250.9     <none>        9187:31086/TCP               63s
service/auth-service-redis-headless              ClusterIP   None            <none>        6379/TCP                     63s
service/auth-service-redis-master                ClusterIP   10.109.108.82   <none>        6379/TCP                     63s
service/auth-service-redis-metrics               NodePort    10.102.57.197   <none>        9121:30534/TCP               63s
service/auth-service-redis-slave                 ClusterIP   10.101.54.126   <none>        6379/TCP                     63s
service/customer-service                         NodePort    10.110.91.237   <none>        9000:30449/TCP               93m
service/customer-service-postgresql              ClusterIP   10.101.90.200   <none>        5432/TCP                     93m
service/customer-service-postgresql-headless     ClusterIP   None            <none>        5432/TCP                     93m
service/customer-service-postgresql-metrics      NodePort    10.99.205.117   <none>        9187:30700/TCP               93m
service/nginx-nginx-ingress-controller           NodePort    10.108.133.32   <none>        80:30185/TCP,443:32061/TCP   95m
service/nginx-nginx-ingress-controller-metrics   ClusterIP   10.97.155.60    <none>        9913/TCP                     95m
service/nginx-nginx-ingress-default-backend      ClusterIP   10.102.251.6    <none>        80/TCP                       95m

NAME                                            DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/nginx-nginx-ingress-controller   1         1         1       1            1           <none>          95m

NAME                                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/auth-service                          3/3     3            3           63s
deployment.apps/customer-service                      3/3     3            3           93m
deployment.apps/nginx-nginx-ingress-default-backend   1/1     1            1           95m

NAME                                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/auth-service-6f978bc96c                          3         3         3       63s
replicaset.apps/customer-service-7cdb99857d                      3         3         3       93m
replicaset.apps/nginx-nginx-ingress-default-backend-679f548db6   1         1         1       95m

NAME                                           READY   AGE
statefulset.apps/auth-service-postgresql       1/1     63s
statefulset.apps/auth-service-redis-master     1/1     63s
statefulset.apps/auth-service-redis-slave      2/2     63s
statefulset.apps/customer-service-postgresql   1/1     93m
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

Для запуска Prometheus:

```
kubectl port-forward -n monitoring service/prom-prometheus-operator-prometheus 9090
```