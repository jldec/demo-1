set -euo pipefail
set -x

ns=$(kubectl get ns nginx-ingress -oname) || true
echo $ns

if [ "$ns" = "" ]; then
  ingress=$(minikube ip)
else
  ingress=$(kubectl get svc/nginx-ingress-controller -n nginx-ingress -ojsonpath='{.status.loadBalancer.ingress[0].ip}')
  if [ "$ingress" = "" ]; then
    ingress=$(kubectl get svc/nginx-ingress-controller -n nginx-ingress -ojsonpath='{.status.loadBalancer.ingress[0].hostname}')
  fi
fi
while read line; do curl -i -X POST -H "Content-Type:application/json" -H "Host: inventory-api.default.example.com" --data "$line" ${ingress}/api/article; done < $1
exit
