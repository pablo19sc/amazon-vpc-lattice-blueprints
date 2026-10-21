.PHONY: deploy deploy-endpoints deploy-common deploy-consumer-group deploy-consumer-single undeploy

REGION = eu-west-1
STACK_PREFIX = vpclattice-advanced-endpoints

deploy: deploy-endpoints deploy-common deploy-consumer-group deploy-consumer-single

deploy-endpoints:
	aws cloudformation deploy --stack-name $(STACK_PREFIX)-provider --template-file centralized_endpoints.yaml --capabilities CAPABILITY_AUTO_EXPAND --no-fail-on-empty-changeset --region $(REGION)

deploy-common:
	aws cloudformation deploy --stack-name $(STACK_PREFIX)-common --template-file common.yaml --capabilities CAPABILITY_NAMED_IAM --no-fail-on-empty-changeset --region $(REGION)

deploy-consumer-group: RESOURCE_CONFIG_GROUP = $(shell aws cloudformation describe-stacks --stack-name "$(STACK_PREFIX)-provider" --query 'Stacks[0].Outputs[?OutputKey == `ResourceConfigurationGroup`].OutputValue' --output text --region $(REGION) )
deploy-consumer-group: INSTANCE_PROFILE = $(shell aws cloudformation describe-stacks --stack-name "$(STACK_PREFIX)-common" --query 'Stacks[0].Outputs[?OutputKey == `InstanceProfile`].OutputValue' --output text --region $(REGION) )
deploy-consumer-group:
	aws cloudformation deploy --stack-name $(STACK_PREFIX)-consumer-group --template-file consumer_group.yaml --parameter-overrides ResourceConfigurationGroup="$(RESOURCE_CONFIG_GROUP)" InstanceProfile="$(INSTANCE_PROFILE)" --capabilities CAPABILITY_AUTO_EXPAND --no-fail-on-empty-changeset --region $(REGION)

deploy-consumer-single: RESOURCE_CONFIGS_SINGLE = $(shell aws cloudformation describe-stacks --stack-name "$(STACK_PREFIX)-provider" --query 'Stacks[0].Outputs[?OutputKey == `ResourceConfigurationsSingle`].OutputValue' --output text --region $(REGION) )
deploy-consumer-single: INSTANCE_PROFILE = $(shell aws cloudformation describe-stacks --stack-name "$(STACK_PREFIX)-common" --query 'Stacks[0].Outputs[?OutputKey == `InstanceProfile`].OutputValue' --output text --region $(REGION) )
deploy-consumer-single:
	aws cloudformation deploy --stack-name $(STACK_PREFIX)-consumer-single --template-file consumer_single.yaml --parameter-overrides ResourceConfigurationsSingle="$(RESOURCE_CONFIGS_SINGLE)" InstanceProfile="$(INSTANCE_PROFILE)" --capabilities CAPABILITY_AUTO_EXPAND --no-fail-on-empty-changeset --region $(REGION)

undeploy:
	aws cloudformation delete-stack --stack-name $(STACK_PREFIX)-consumer-group --region $(REGION)
	aws cloudformation delete-stack --stack-name $(STACK_PREFIX)-consumer-single --region $(REGION)
	aws cloudformation wait stack-delete-complete --stack-name $(STACK_PREFIX)-consumer-group --region $(REGION)
	aws cloudformation wait stack-delete-complete --stack-name $(STACK_PREFIX)-consumer-single --region $(REGION)
	aws cloudformation delete-stack --stack-name $(STACK_PREFIX)-common --region $(REGION)
	aws cloudformation delete-stack --stack-name $(STACK_PREFIX)-provider --region $(REGION)
	aws cloudformation wait stack-delete-complete --stack-name $(STACK_PREFIX)-common --region $(REGION)
	aws cloudformation wait stack-delete-complete --stack-name $(STACK_PREFIX)-provider --region $(REGION)
