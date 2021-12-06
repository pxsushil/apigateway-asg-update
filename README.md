# apigateway-asg-update


API to update AutoScaling group (values for min, max, and desired count as values for the mentioned autoscaling group.)

Step1:- First we are creating an s3 bucket and an object (Lambda function code ) into it.
For that, we have an s3 directory for Terraform code first we will deploy that.

```
.. /S3 $terraform apply

```
Step 3:- Now we are creating policies and roles for the communication between AWS resources also creating Lambda function and API Gateway. Terraform script for the same is inside Terraform directory. 

```
../Terraform $terraform apply
```
Step 4:- This will give and invoke_url (Post API URL)

```
complete_invoke_url = "https://5tbkkuk676.execute-api.us-east-1.amazonaws.com/dev/resource"
```

Step 5:- In this, we will pass our parameters (ASG-Name,CesiredCapacity,MinimumCapacity,MaximumCapacity)
```
https://5tbkkuk676.execute-api.us-east-1.amazonaws.com/dev/resource?

```

```
curl --location --request POST 'https://izoaehgcz1.execute-api.us-east-1.amazonaws.com/dev/resource?ASG-Name=testScaling&DesiredCapacity=0&MinimumCapacity=0&MaximumCapacity=0'
```

Output Sample

```
{
    "ASG-Name": "testScaling",
    "CesiredCapacity": 0,
    "MinimumCapacity": 0,
    "MaximumCapacity": 0,
    "Status": "The auto scaling group --> testScalingis successfully updated "
}
```
