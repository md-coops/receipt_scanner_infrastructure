ENV ?= dev

.PHONY: plan apply destroy fmt validate

plan:
	cd envs/$(ENV) && terraform init -input=false && terraform plan -var-file=terraform.tfvars

apply:
	cd envs/$(ENV) && terraform init -input=false && terraform apply -var-file=terraform.tfvars

destroy:
	cd envs/$(ENV) && terraform init -input=false && terraform destroy -var-file=terraform.tfvars

fmt:
	terraform fmt -recursive

validate:
	cd envs/$(ENV) && terraform init -backend=false -input=false && terraform validate
