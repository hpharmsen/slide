## How to Control your slide with Alexa, part 1, deploy to AWS
#### 1. Create a trust-policy.json file
This should look like the following. 
Do not change the version date.

```javascript
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

#### 2. Create an Access Key 
To do this visit: https://console.aws.amazon.com/iam/home?region=us-east-1#/security_credentials

Choose: Access keys (access key ID and secret access key)

You need to have or sign up for an Amazon account.
#### 3. Configure AWS
Make sure you have installed the AWS CLI. If not install it via https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html

`aws configure`

Fill in the Access keys you just created,  
set Default region name to `us-east-1` (unless you use another region)
and Default output format to `json`.

Run the following to set the right permissions

`aws iam create-role --role-name lambda-ex --assume-role-policy-document file://trust-policy.json`

`aws iam attach-role-policy --role-name lambda-ex --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole`

And find out your AWS account Id. To do this run

`aws sts get-caller-identity`

This returns something like:

```javascript
{
    "UserId": "822854244165",
    "Account": "822854244165",
    "Arn": "arn:aws:iam::822854244165:root"
}
```
### 4. Create a deployment package.
`zip function.zip slide.py slide_lambda.py`

### 5. Create the lambda function
`aws lambda create-function --function-name slide_test 
--zip-file fileb://function.zip --handler lambda_function.lambda_handler --runtime python3.8 
--role arn:aws:iam::822854244165:role/lambda-ex`

In aws console set Environment variables `slide_email` and `slide_password` to your Slide login credentials 
and set `Timeout` to 15 sec.

### 6. Updating the function
`aws lambda update-function-code --function-name slide_test --zip-file fileb://function.zip`

Or use the included deploy.sh script.

### 7. Testing
To invoke the function:
`aws lambda invoke --function-name slide_test out --log-type Tail`

Or run the test from the AWS console

---
Credits: https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-awscli.html
