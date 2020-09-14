provider "aws" {
  region = "us-east-1"
}

locals {
  lambda_file = "${path.module}/source/hello_world.py"
}

data "template_file" "lambda_file" {
  template = file(local.lambda_file)
}

resource "local_file" "to_temp_dir" {
  filename = "${path.module}/source/package/${basename(local.lambda_file)}"
  content  = data.template_file.lambda_file.rendered
}

data "archive_file" "lambda_source" {
  type        = "zip"
  output_path = "${path.module}/tmp/function.zip"
  source_dir  = "${path.module}/source/package/"

  depends_on = [
    local_file.to_temp_dir,
  ]
}

resource "aws_lambda_function" "hello_world" {
  function_name = "hello_world"

  filename         = data.archive_file.lambda_source.output_path
  source_code_hash = data.archive_file.lambda_source.output_base64sha256

  handler = "hello_world.hello_world_handler"
  runtime = "python3.7"

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_iam_role" "lambda_exec" {
  name = "hello_world_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

##configured resource and method to handle incoming requests to API gateway, proxy+ and http method "ANY" indicates all incoming requests will match this resource
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.hello_world_api.id
  parent_id   = aws_api_gateway_rest_api.hello_world_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.hello_world_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

##permission to access api gateway
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.hello_world_api.execution_arn}/*/*"
}