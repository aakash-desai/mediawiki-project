[cmdletbinding()]
$SUBSCRIPTION = ""
$RESOURCEGROUP = ""
$CLUSTERNAME = ""
$MediaWikiNameSpace   = "wiki"

Push-Location $PSScriptRoot

write-host "SET SUBSCRIPTION"
az account set --subscription $SUBSCRIPTION
Write-Host "Subscription set to $SUBSCRIPTION"

write-host "GET $CLUSTERNAME CREDENTIALS"
az aks get-credentials --resource-group $RESOURCEGROUP --name $CLUSTERNAME

#Set cluster
kubectl config use-context $CLUSTERNAME

write-host "CREATE $MediaWikiNameSpace  NAMESPACE"
$NameSpace=$(kubectl get namespace $MediaWikiNameSpace  --ignore-not-found)

if ($NameSpace) {
    Write-Host "Skipping creation of $MediaWikiNameSpace  - already exists"
} else {
    kubectl create namespace $MediaWikiNameSpace 
    Write-Host "namespace $NameSpace  created"
}

write-host "Add Bitnami MediaWiki Helm Chart Repository"

helm repo add bitnami https://charts.bitnami.com/bitnami

write-host "Update Helm Repository"

helm repo update

write-host "Apply Bitnami MediaWiki Helm Chart Repository"

helm install mediawiki -n wiki bitnami/mediawiki

write-host "Getting Deployment Values"

$APP_HOST=$(kubectl get svc --namespace wiki mediawiki --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
echo "Application Host: $APP_HOST"

$APP_PASSWORD= $([Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($(kubectl get secret --namespace wiki mediawiki -o jsonpath="{.data.mediawiki-password}"))))
echo "Application Password: $APP_PASSWORD"

$MARIADB_ROOT_PASSWORD=$([Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($(kubectl get secret --namespace wiki mediawiki-mariadb -o jsonpath="{.data.mariadb-root-password}"))))
echo "MariaDb Root Password: $MARIADB_ROOT_PASSWORD"

$MARIADB_PASSWORD=$([Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($(kubectl get secret --namespace wiki mediawiki-mariadb -o jsonpath="{.data.mariadb-password}"))))
echo "MariaDb Password: $MARIADB_PASSWORD"

write-host "Upgrade Helm Deployment"
helm upgrade --namespace wiki mediawiki bitnami/mediawiki --set mediawikiHost=$APP_HOST,mediawikiPassword=$APP_PASSWORD,mariadb.auth.rootPassword=$MARIADB_ROOT_PASSWORD,mariadb.auth.password=$MARIADB_PASSWORD

write-host "Please use following credentials to login"

$SERVICE_IP=$(kubectl get svc --namespace wiki mediawiki --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")

echo "Mediawiki URL: http://$SERVICE_IP/"
echo Username: user
echo Password: $([Text.Encoding]::Utf8.GetString([Convert]::FromBase64String( $(kubectl get secret --namespace wiki mediawiki -o jsonpath="{.data.mediawiki-password}"))))
