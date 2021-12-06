
#---------------------------------------------
              #IAM policy
#---------------------------------------------
resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
         "logs:CreateLogGroup",
         "logs:CreateLogStream",
         "logs:PutLogEvents",
          "s3:*",
          "apigateway:*",
          "cloudwatch:*",
          "autoscaling:*",
          "ec2:Describe*",
          "lambda:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

#---------------------------------------------
      #IAM Role
#---------------------------------------------

resource "aws_iam_role" "UniRole" {
  name = "UniRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}


#---------------------------------------------
      #Creating aws_lambda_function 
#---------------------------------------------


resource "aws_lambda_permission" "apigw_lambda" {
   depends_on = [
    "aws_lambda_function.lambda",
    "aws_api_gateway_rest_api.myapi",
    "aws_api_gateway_method.method"
  ]
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_function" "lambda" {
  s3_bucket     = "accept-api-gateway-parameters"
  s3_key        = "lambda_function.zip"
  function_name = "lambda_function_Accept_Parameters"
  role          = aws_iam_role.UniRole.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
  ]

}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.UniRole.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}





#---------------------------------------------
      #Creating API Gateway
#---------------------------------------------


resource "aws_api_gateway_rest_api" "myapi" {
  name = "getParametersForASG"
  description = "Get asg Parameters	"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  depends_on = [
    "aws_lambda_function.lambda"
  ]
}

resource "aws_api_gateway_resource" "resource" {
  path_part   = "resource"
  parent_id   = aws_api_gateway_rest_api.myapi.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.myapi.id
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.myapi.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required  = false
}


resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id             = aws_api_gateway_rest_api.myapi.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  status_code             = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "integration" {
depends_on = [
    "aws_lambda_permission.apigw_lambda",
    "aws_api_gateway_method_response.response_200"
  ]
  rest_api_id             = aws_api_gateway_rest_api.myapi.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
 
}

#---------------------------------------------
          #Deployment of API gateway 
#---------------------------------------------

resource "aws_api_gateway_deployment" "apideploy" {
   depends_on = [
    "aws_api_gateway_integration.integration",
    "aws_api_gateway_method.method",
    "aws_api_gateway_integration_response.Integration_response",
    "aws_api_gateway_method_response.response_200"
   ]
   rest_api_id = aws_api_gateway_rest_api.myapi.id
   stage_name  = "dev"
}

resource "aws_api_gateway_integration_response" "Integration_response" {
  depends_on = [
    "aws_api_gateway_integration.integration"
  ]
  rest_api_id             = aws_api_gateway_rest_api.myapi.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  status_code             = aws_api_gateway_method_response.response_200.status_code
}


#---------------------------------------------
          # Output with invoke URL
#---------------------------------------------
output "complete_invoke_url"   {value = "${aws_api_gateway_deployment.apideploy.invoke_url}/${aws_api_gateway_resource.resource.path_part}"}