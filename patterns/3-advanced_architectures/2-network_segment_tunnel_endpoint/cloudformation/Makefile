.PHONY: deploy deploy-provider deploy-consumer undeploy

deploy: deploy-provider deploy-consumer

deploy-provider:
	aws cloudformation deploy --stack-name vpclattice-tunnel-provider --template-file provider.yaml --no-fail-on-empty-changeset --region eu-west-1

deploy-consumer: RESOURCECONFIG = $(shell aws cloudformation describe-stacks --stack-name "vpclattice-tunnel-provider" --query 'Stacks[0].Outputs[?OutputKey == `ResourceConfigurationArn`].OutputValue' --output text --region eu-west-1 )
deploy-consumer: SEGMENTCIDRS = $(shell aws cloudformation describe-stacks --stack-name "vpclattice-tunnel-provider" --query 'Stacks[0].Outputs[?OutputKey == `NetworkSegmentCidrs`].OutputValue' --output text --region eu-west-1 )
deploy-consumer:
	aws cloudformation deploy --stack-name vpclattice-tunnel-consumer --template-file consumer.yaml --parameter-overrides ResourceConfigurationArn="$(RESOURCECONFIG)" SegmentCidrs="$(SEGMENTCIDRS)" --capabilities CAPABILITY_IAM --no-fail-on-empty-changeset --region eu-west-1

undeploy:
	aws cloudformation delete-stack --stack-name vpclattice-tunnel-consumer --region eu-west-1
	aws cloudformation wait stack-delete-complete --stack-name vpclattice-tunnel-consumer --region eu-west-1
	aws cloudformation delete-stack --stack-name vpclattice-tunnel-provider --region eu-west-1
	aws cloudformation wait stack-delete-complete --stack-name vpclattice-tunnel-provider --region eu-west-1
