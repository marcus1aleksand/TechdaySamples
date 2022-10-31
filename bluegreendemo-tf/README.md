IMPORTANT, this should be staging ... not quite. Toggle traffic to auto scale up green and auto scale down blue for high aks resource usage, and shared persistent data across blue and green so as to not replicate the large portion of data. This is how to do this cost affectively.

# Pre-requisites

Before running this, Before running bluegreen-rf, run the bluegreen-tf-bootstrap/ build. **IMPORTANT** - Do not do the following if this already exists, check if exists.
```
cd bluegreen-tf-bootstrap/
terraform init
terrafrom plan
terraform apply
```

Get the access key automatically generated on ACR creation. Go to the container registry and select access keys. The following are needed:
* The username is the acr name.
* The password is dynamically generated.
* The login server to pass to the docker login statement. 

Build app and push image:
```
cd testAPI/
docker build -t devjambluegreen.azurecr.io/blue-green-api:latest . -f docker/Dockerfile 
docker login devjambluegreen.azurecr.io # Use username and password from access keys section on the container registry.
docker push devjambluegreen.azurecr.io/blue-green-api:latest
```

# Process

See available vesrions for the location we are using:
```
az aks get-versions -l eastus
```

Set the version to an older version to start, build env, and then upgrade one aks instance at a time. From variables.tf:
```
variable "blue_vesrion" {
    default = "1.24.0"
}

variable "green_vesrion" {
    default = "1.24.0"
}
```

Clear old states (for testing):
```
rm -r terraform.tfstate
rm -r .terraform
rm -r .terraform.lock.hcl
```

Run:
```
# For connecting to a remote state file.
# If upgrading azurem, add '-upgrade' to the end of the statement below. #
terraform init \
  -var-file="templates.tfvars" \
  -backend-config="resource_group_name=devjam-bluegreen-bootstrap" \
  -backend-config="storage_account_name=devjambluegreen" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=ja.devjambluegreen.terraform.tfstate"

terraform plan -var-file="templates.tfvars"
terraform apply -var-file="templates.tfvars"
```

Connect to clusters (the resource group name and the aks cluster names will change based on templates.tfvars file):
```
az aks get-credentials --resource-group ja-test-4-tf --name jatest4tf-aks-blue
az aks get-credentials --resource-group ja-test-4-tf --name jatest4tf-aks-green
```

Can toggle the weights on traffic manager to control flow:
```
...

resource "azurerm_traffic_manager_external_endpoint" "blue" {
  ...
  weight     = 50
  ...
}

resource "azurerm_traffic_manager_external_endpoint" "green" {
  ...
  weight     = 50
  ...
}

...
```

**IMPORTANT**: For running testAPI/ the image pushed at the beginning of this process in pre-requisites, it takes an env variable that is the cluster id. These are defined in the helm chart deployments for blue and green. If additional data needs to be collected, keep in mind to sync these helm deployments with the app code.

Testing blue-green deployments:
1. Start the above, and test that traffic is flowing. Use ../accessScript/.
2. Update TF to toggle 'weight = 0' on green and 'weight = 100' on blue. Apply TF.
3. Test that traffic is flowing only to blue.
4. Update TF to increase version on aksgreen. Apply TF. Test that it has been updated in Azure.
5. Update TF to toggle 'weight = 100' on green and 'weight = 0' on blue. Apply TF.
6. Test that traffic is flowing only to green and that green is functioning properly.

The test is to show how we can toggle to do upgrades and provides a rollback strategy. In a live system, we would toggle weights for 20 on green (canary) and 80 on blue before moving to 100 on green.

TODO:
* Have a way to test green before toggling any traffic to green.

# Clean Up

Run:
```
terraform destroy -var-file="templates.tfvars"
```
