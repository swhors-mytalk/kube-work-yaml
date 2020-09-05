# kube-work-yaml

## 일반 적인 적용 순서
1. kubectl apply -f *deploy.yaml
2. kubectl apply -f autoscaling.yaml
3. kubectl apply -f *service.yaml

## 인그레스 주의 사항
1. 일반 API는 bemily-ingress에 추가하여 적용합니다.
2. file API는 bemily-file-ingress에 추가하여 적용합니다.

* 신규 적용의 경우에는 bemily-ingress를 편집하시고 적용하여 주십시요.
* 위 bemily-ingress는 dev 환경에서 사용 된 값을 기본으로 갖고 있습니다.
* dev에서 옮겨오는 경우, bemily-ingress