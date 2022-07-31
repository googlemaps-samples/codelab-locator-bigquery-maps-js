PROJECT_ID=$(gcloud config get-value project)
cd terraform
sed -i "s|PROJECT_ID|$PROJECT_ID|g" terraform.tfvars 
terraform init
terraform apply --auto-approve