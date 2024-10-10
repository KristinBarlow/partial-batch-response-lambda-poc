variable "aws_region" {
  default     = "us-west-2"
  description = "AWS region for the deployment"
  type        = string
}

variable "aws-region-id" {
  description = "A region identifier following standards defined at https://tlvconfluence01.nice.com/display/IN/Region+IDs"
  type        = string
}

variable "vc-grpc-port" {
  default     = 9884
  description = "The port that will be used to communicate with the VC via GRPC."
  type        = number
}

variable "lambda-debug-logging" {
  default     = false
  description = "This will enable or disable debug level logging within the lambda function code."
  type        = bool
}

variable "lambda-memory-megabytes" {
  default     = 512
  description = "The number of memory megabytes that will be allocated to the lambda function."
  type        = number
}

variable "resource-prefix" {
  default     = "entitymanagement"
  description = "A prefix that will be prepended into the name of all created AWS resources."
  type        = string
}

variable "role_serviceaccess_case_state_lambda" {
  default     = "ServiceAccess-digi-case-state-lambda"
  description = "The IAM role that will be set on the lambda function."
  type        = string
}

variable "zip_file_name" {
  default = "bootstrap.zip"
  description = "The name of the zip file containing the compiled go binary which will be uploaded to AWS Lambda."
  type = string
}

variable "tenant-cluster-map"{
  description = "The name for the tenant cluster map we use for lookups."
  type = string
}

variable "test-stream-output"{
  default = ""
  description = "The output stream used for automation"
  type = string
}

variable "cloudformation-export_lambda-subnets" {
  default     = ["CoreNetwork-Az1LambdaSubnet", "CoreNetwork-Az2LambdaSubnet"]
  description = "The names of 1 or more Cloudformation Exports that contain ID's of subnets which will be used by Lambda."
  type        = set(string)
}

variable "configured_de_events_streams" {
  default     = []
  description = "List of Digital Engagement deployed event streams for the environment that should be registered for consumption (e.g., [\"case\",\"entitymanagement-digimiddleware-events-stream-test-do\"])."
  type        = list(string)
}

variable "environment"{
  description = "where is this deployed too? dev,test,staging, prod"
  default = "nan"
  type = string
}

variable "lambda-version-branch-name" {
  default     = "default"
  description = "This represents the name of the branch that this lambda was deployed from to help with troubleshooting."
  type        = string
}

variable "lambda-version-hash" {
  default     = "default"
  description = "This represents the hash version of the branch to determine which version of the service is deployed."
  type        = string
}
