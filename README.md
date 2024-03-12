# MediaWiki Deployment

### Deployment Details

***
> Bootstrapped Helm Chart Enable Deployment of MediaWiki and MariaDB in Azure Kubernetes Service (AKS)
***

***
> Terraform Scripts for creating and configuring Azure Kubernetes Service and prerequisuite
***

### How to use

#### Terraform

* Change directory to "Infrastructure" folder
```powershell
cd \mediawiki\infra
```
* Update default variables in "**terraform.tfvars**"

* Initialize : Initializes a Terraform project by setting up necessary plugins, providers, and state management.
```powershell
terraform init
```
* Planning : Terraform configuration to determine the desired state of all the resources it declares.
```powershell
terraform plan
```
* Applying: Applies planned changes 
```powershell
terraform apply
```
#### Above steps will create,
***
>  * Azure Resource Group.
***
>  * Azure Kubernetes Service.
***
>  * Virtual Network and subnet for Azure Kubernetes Service.

***
>  * Select Azure CNI as a networking with Azure Network Policies.
***
>  * Creates System Assigned Identity to provide acces to other Azure resources.
***
>  * Node pool with auto scaling enabled between 3 to 11 nodes.
***

#### Helm Deployment to Azure Kubernetes Service
* Change directory to "mediawiki_deployment"
```powershell
cd \mediawiki\mediawiki_deployment
```
* Update values or provide as arguments to "**deployMediaWiki.ps1**"
```powershell
$SUBSCRIPTION = "<subscription-id>"
$RESOURCEGROUP = "<resource-group-name>"
$CLUSTERNAME = "<cluster-name>"

* Powershell script is using Bitnami MediaWiki Helm Chart Repository to deploy MediaWiki and MariaDb.
* Deployment of Helm chart is automated and script will provide MediaWiki URL, Username and Password in following format.
```powershell
Mediawiki URL: http://<LoadBalancer-IP>/
Username: user
Password: <password-from-secret>
```
## Results
Scalable Instance of WikiMedia running in secure network Azure Kubernetes Service and exposed out of LoadBalancerIP.

### References 
* https://artifacthub.io/packages/helm/bitnami/mediawiki
* https://bitnami.com/stack/mediawiki
* https://github.com/bitnami/bitnami-docker-mediawiki
