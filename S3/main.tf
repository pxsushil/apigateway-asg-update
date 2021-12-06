provider "aws"{
  region     = "us-east-1"
}


#---------------------------------------------
              #archiving_file for S3
#---------------------------------------------

resource "archive_file" "fixture" {

  type        = "zip"
  source_file         = "/home/professor/Desktop/ApiGateway,lambda,Update ASG/lambda_function.py"
  output_path        = "/home/professor/Desktop/ApiGateway,lambda,Update ASG/lambda_function.zip"

}

#---------------------------------------------
              #Creating S3
#---------------------------------------------

resource "aws_s3_bucket" "examplebucket" {
  depends_on = [
    "archive_file.fixture",
  ]
  bucket = "accept-api-gateway-parameters"
  acl    = "private"
}

#---------------------------------------------
              #Creating S3 object
#---------------------------------------------

resource "aws_s3_bucket_object" "examplebucket_object" {
    depends_on = [
    "aws_s3_bucket_object.examplebucket_object",
    "archive_file.fixture",
  ]
  key    = "lambda_function.zip"
  bucket = aws_s3_bucket.examplebucket.id
  source = "/home/professor/Desktop/ApiGateway,lambda,Update ASG/lambda_function.zip"
  force_destroy = true
}