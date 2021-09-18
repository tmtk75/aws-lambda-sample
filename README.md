See this repository for rich examples.
https://github.com/tmtk75/aws-lambda-container-sample

----
AWS Lambda example using terraform and awscli.

- Create a lamnda function which performe Get and Put to S3.
- Create an IAM role for the lambda function
- Create a S3 bucket to be used for test

```
$ make tf-plan
$ make tf-apply
$ make event-source-config
$ make s3-cp
$ make s3-ls
```

TBD
