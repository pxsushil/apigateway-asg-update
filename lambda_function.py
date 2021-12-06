import json
import boto3


client=boto3.client('autoscaling')
def lambda_handler(event, context):
    asgName = event['queryStringParameters']['ASG-Name']
    desiredCapacity = int(event['queryStringParameters']['DesiredCapacity'])
    minValue = int(event['queryStringParameters']['MinimumCapacity'])
    maxValue = int(event['queryStringParameters']['MaximumCapacity'])
    

    response = client.update_auto_scaling_group(
    AutoScalingGroupName= asgName,
    DesiredCapacity= desiredCapacity,
    MaxSize= maxValue,
    MinSize= minValue)
    print(response)
#Body of the response
    apiResponse = {}
    apiResponse['ASG-Name'] = asgName
    apiResponse['CesiredCapacity'] = desiredCapacity
    apiResponse['MinimumCapacity'] = minValue
    apiResponse['MaximumCapacity'] = maxValue
    apiResponse['Status'] = 'The auto scaling group' + " --> " + asgName + ' is successfully updated'
#HTTP response 
    responseObject = {}
    responseObject['statusCode'] = 200
    responseObject['headers'] ={}
    responseObject['headers']['Content-Type'] = 'application/json'
    responseObject['body'] =json.dumps(apiResponse)


    return responseObject
    
