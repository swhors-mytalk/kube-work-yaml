## DEPLOY PROMETHEUS

 1. kubectl create ns monitoring
 2. kubectl apply -f prometheus-cluster-role.yaml
 3. kubectl apply -f prometheus-pv-volume.yaml
 4. kubectl apply -f prometheus-pvc-volume.yaml
 5. kubectl apply -f prometheus-config-map.yaml
 6. kubectl apply -f prometheus-deployment.yaml
 7. kubectl apply -f prometheus-node-exporter.yaml
 8. kubectl apply -f prometheus-svc.yaml
