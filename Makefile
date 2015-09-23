##
## Regarding AWS CLI operations to add event-source-mapping to S3,
## I referred the following site.
## http://dev.classmethod.jp/cloud/aws/tips-lambda-eventsource-s3/
##
lambda-funcs.zip: *.js
	zip -r lambda-funcs.zip *.js

tf-plan: lambda-funcs.zip
	terraform plan

tf-apply: lambda-funcs.zip
	terraform apply

lambda-permission:
	aws lambda add-permission \
		--function-name "s3-lambda" \
		--statement-id "s3-put-event" \
		--action "lambda:InvokeFunction" \
		--principal "s3.amazonaws.com" \
		--source-arn "arn:aws:s3:::`terraform output bucket.id`"

show-permission:
	aws lambda get-policy --function-name "s3-lambda"

s3-notification:
	aws s3api put-bucket-notification-configuration \
		--bucket "`terraform output bucket.id`" \
		--notification-configuration '{"LambdaFunctionConfigurations": [{"LambdaFunctionArn": "'`terraform output lambda.arn`'", "Events": ["s3:ObjectCreated:*"], "Filter": {"Key": {"FilterRules": [{"Name": "prefix", "Value": "targets"}]}}}]}'

show-notification:
	aws s3api get-bucket-notification-configuration \
		--bucket "`terraform output bucket.id`"

event-source-config: lambda-permission s3-notification

# This is for DynamoDB & Kinesis
#event-src:
#	aws lambda create-event-source-mapping \
#		--event-source-arn arn:aws:s3:::`terraform output bucket.id` \
#		--function-name s3-lambda \
#		--starting-position LATEST \
#		--enabled

a.txt:
	\ls > a.txt

s3-cp: a.txt
	aws s3 cp a.txt s3://`terraform output bucket.id`/targets/a-`date +%s`.txt

s3-ls:
	aws s3 ls --recursive s3://`terraform output bucket.id`/

clean-s3:
	aws s3 rm --recursive s3://`terraform output bucket.id`/

rm-func:
	terraform destroy -target aws_lambda_function.s3-lambda

events:
	aws logs get-log-events \
		--log-group-name /aws/lambda/s3-lambda \
		--log-stream-name `make logs | jq -r ".logStreams[0].logStreamName"`

logs:
	@aws logs describe-log-streams --log-group-name /aws/lambda/s3-lambda

groups:
	aws logs describe-log-groups

rm-lambda-settings:
	aws lambda remove-permission \
		--function-name "s3-lambda" \
		--statement-id "s3-put-event"
	aws s3api put-bucket-notification-configuration \
		--bucket "`terraform output bucket.id`" \
		--notification-configuration "{}"



