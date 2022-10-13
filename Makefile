.PHONY: test
include .env

TF_RUN=terraform -chdir=terraform/assets

run-operator:
	AZURE_CLIENT_ID=${AZURE_CLIENT_ID} \
	AZURE_TENANT_ID=${AZURE_TENANT_ID} \
	AZURE_CLIENT_SECRET=${AZURE_CLIENT_SECRET} \
	SUBSCRIPTION_ID=${SUBSCRIPTION_ID} \
	RESOURCE_GROUP_NAME=${RESOURCE_GROUP_NAME} \
	DNS_ZONE_NAME=${DNS_ZONE_NAME} \
	APPGW_IP_ADDRESS=${APPGW_IP_ADDRESS} \
	kopf run -A --verbose appgw_external_dns/main.py

test:
	AZURE_CLIENT_ID=${AZURE_CLIENT_ID} \
	AZURE_TENANT_ID=${AZURE_TENANT_ID} \
	AZURE_CLIENT_SECRET=${AZURE_CLIENT_SECRET} \
	SUBSCRIPTION_ID=${SUBSCRIPTION_ID} \
	RESOURCE_GROUP_NAME=${RESOURCE_GROUP_NAME} \
	DNS_ZONE_NAME=${DNS_ZONE_NAME} \
	APPGW_IP_ADDRESS=${APPGW_IP_ADDRESS} \
	APPGW_NAME=${APPGW_NAME} \
	../../bin/pytest -s

tf-init:
	ARM_ACCESS_KEY=${ARM_ACCESS_KEY} \
		$(TF_RUN) init -reconfigure \
		-backend-config="resource_group_name=${RESOURCE_GROUP_NAME}" \
		-backend-config="storage_account_name=${STORAGE_ACCOUNT_NAME}" \
		-backend-config="container_name=${CONTAINER_NAME}" \
		-backend-config="key=${CONTAINER_KEY}"

plan: tf-init
	$(TF_RUN) plan \
		-var-file=../environment/${ENV}.tfvars \
		-input=false

apply: tf-init
	$(TF_RUN) apply -auto-approve \
		-var-file=../environment/${ENV}.tfvars \
		-input=false

destroy: tf-init
	$(TF_RUN) destroy -auto-approve \
		-var-file=../environment/${ENV}.tfvars \
		-input=false

show-secrets:
	$(TF_RUN) output -json

delete-all:
	az group delete -n ${RESOURCE_GROUP_NAME} -y
