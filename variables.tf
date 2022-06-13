variable "function_name" {
  type    = string
  default = "Bossy"
}

variable "function_description" {
  type    = string
  default = "The Cloud Posse Bossy Bot"
}

variable "s3_bucket" {
  description = <<EOF
  The S3 bucket location containing the function's deployment package. This bucket must reside in the same AWS region 
  where you are creating the Lambda function. If not specified, the lambda will be deployed from Cloud Posse's canonical
  S3 bucket in the region you are deploying to.
  EOF
  default     = null
  type        = string
}

variable "s3_key" {
  description = <<EOF
  The S3 key of an object containing the function's deployment package. If not specified, the lambda will be deployed 
  from Cloud Posse's canonical S3 bucket in the region you are deploying to.
  EOF
  default     = null
  type        = string
}

variable "lambda_zip_version" {
  description = <<EOF
  The version of the Lambda function.
  EOF
  default     = "pr-36"
  type        = string
}

variable "memory_size" {
  description = "Amount of memory in MB the Lambda Function can use at runtime."
  default     = 1024
  type        = number
}

variable "api_gateway_title" {
  type    = string
  default = "API Gateway for Cloud Posse Bossy Bot"
}

variable "api_gateway_version" {
  type    = string
  default = "v1"
}

variable "api_gateway_logging_level" {
  type        = string
  description = "The logging level of the API. One of - OFF, INFO, ERROR"
  default     = "INFO"

  validation {
    condition     = contains(["OFF", "INFO", "ERROR"], var.api_gateway_logging_level)
    error_message = "Valid values for var: logging_level are (OFF, INFO, ERROR)."
  }
}

variable "enable_api_gateway_account_settings" {
  type        = bool
  description = "Flag to enable the API Gateway Account settings if not previously enabled."
  default     = false
}

variable "slack_oauth_token" {
  description = "Value of the BOSSY_SLACK_OAUTH_TOKEN environment variable"
  type        = string
}

variable "slack_secret" {
  description = "Value of the BOSSY_SLACK_SECRET environment variable"
  type        = string
}

variable "slack_signing_secret" {
  description = "Value of the BOSSY_SLACK_SIGNING_SECRET environment variable"
  type        = string
}

variable "spacelift_to_slack_channel" {
  description = "Value of the BOSSY_SPACELIFT_TO_SLACK_CHANNEL environment variable"
  type        = string
}
