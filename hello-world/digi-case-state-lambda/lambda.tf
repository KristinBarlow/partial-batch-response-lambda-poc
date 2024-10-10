data "aws_iam_role" "ServiceAccess-digi-case-state-lambda" {
  name = var.role_serviceaccess_case_state_lambda
}

data "aws_kinesis_stream" "case_stream" {
  name = "${var.aws-region-id}-de-case-events-stream"
}

data "aws_kinesis_stream" "test_stream" {
  name = "${var.resource-prefix}-digimiddleware-events-stream-test-${var.aws-region-id}"
}

locals {
  aws_case_state_lambda_name = "${var.resource-prefix}-digi-case-state-relay-lambda-${var.aws-region-id}"
  de_stream_names = {
    case_stream_arn = data.aws_kinesis_stream.case_stream.arn
    aws_kinesis_stream_events_test_stream_name = data.aws_kinesis_stream.test_stream.arn
  }
}

resource "aws_security_group" "lambda" {
  name        = local.aws_case_state_lambda_name
  description = "Security Group to allow access for ${local.aws_case_state_lambda_name} lambda function"
  vpc_id      = data.aws_subnet.lambda[element(tolist(var.cloudformation-export_lambda-subnets), 0)].vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(
    local.common_tags,
    {
      "Name" = local.aws_case_state_lambda_name
    }
  )
}

data "aws_cloudformation_export" "lambda_subnets" {
  for_each = var.cloudformation-export_lambda-subnets
  name     = each.value
}

data "aws_subnet" "lambda" {
  for_each = data.aws_cloudformation_export.lambda_subnets
  id       = each.value.value
}

resource "aws_lambda_function" "case_state_lambda" {
  function_name    = local.aws_case_state_lambda_name
  filename         = var.zip_file_name
  handler          = "bootstrap"
  role             = data.aws_iam_role.ServiceAccess-digi-case-state-lambda.arn
  source_code_hash = filebase64sha256(var.zip_file_name)
  runtime          = "provided.al2"
  timeout          = 30
  architectures    = ["arm64"]

  environment {
    variables = {
      Lambda = terraform.workspace
      AwsRegion = var.aws_region
      Environment = var.aws-region-id
      DebugLogging = var.lambda-debug-logging
      TenantClusterMap = "${var.resource-prefix}-${var.tenant-cluster-map}-${var.aws-region-id}"
      TestStreamOut = var.test-stream-output == "" ? "" : "${var.resource-prefix}-${var.aws-region-id}-${var.test-stream-output}"
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.lambda.id]
    subnet_ids         = [for value in data.aws_subnet.lambda : value.id]
  }

  tags = merge(
    local.common_tags,
    tomap({
      "Name" : local.aws_case_state_lambda_name,
      "DeviceType" : "AWS Lambda Function",
    })
  )
}

resource "aws_kinesis_stream_consumer" "case_state_lambda_consumer" {
  for_each   = local.de_stream_names
  name       = local.aws_case_state_lambda_name
  stream_arn = local.de_stream_names[each.key]
}

resource "aws_lambda_event_source_mapping" "case_state_lambda_event_source_mapping" {
  for_each          = aws_kinesis_stream_consumer.case_state_lambda_consumer
  event_source_arn  = each.value.arn
  function_name     = aws_lambda_function.case_state_lambda.function_name
  batch_size        = 200
  parallelization_factor = 2
  starting_position = "LATEST"
  maximum_retry_attempts = 3
  filter_criteria {
    [
      {
        "Pattern": "{\"data\":{\"eventType\":[\"CaseStatusChanged\"]}}"
      }
    ]
}
