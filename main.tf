locals {
  enabled       = module.this.enabled
  enabled_count = local.enabled ? 1 : 0
  #bucket        = format("cplive-core-%s-public-bossy-artifacts", module.utils.region_az_alt_code_maps.to_fixed[data.aws_region.this.name])
  bucket        = "cplive-core-ue2-public-bossy-artifacts"
  artifact_path = format("bossy/lambda-bossy-%s.zip", var.lambda_zip_version)
}

module "utils" {
  enabled = var.enabled
  source  = "cloudposse/utils/aws"

  context = module.this.context
}

data "aws_region" "this" {}

module "label" {
  count      = local.enabled_count
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  attributes = [var.function_name]

  context = module.this.context
}

module "bossy_lambda" {
  enabled = var.enabled
  source  = "cloudposse/lambda-function/aws"
  version = "0.3.2"

  function_name = module.label[0].id
  description   = var.function_description
  publish       = true

  s3_bucket = local.bucket
  s3_key    = local.artifact_path

  lambda_environment = {
    variables = {
      "BOSSY_SLACK_OAUTH_TOKEN"          = var.slack_oauth_token,
      "BOSSY_SLACK_SECRET"               = var.slack_secret,
      "BOSSY_SLACK_SIGNING_SECRET"       = var.slack_signing_secret,
      "BOSSY_SPACELIFT_TO_SLACK_CHANNEL" = var.spacelift_to_slack_channel,
      "BOSSY_LOGGING_LEVEL"              = "debug",
    }
  }

  memory_size = var.memory_size
  runtime     = "nodejs14.x"
  handler     = "main.handler"

  context = module.this.context
}

module "api_gateway_account_settings" {
  source  = "cloudposse/api-gateway/aws//modules/account-settings"
  version = "0.0.2"
  count   = var.enable_api_gateway_account_settings ? 1 : 0

  enabled = local.enabled
  context = module.this.context
}

module "api_gateway" {
  source  = "cloudposse/api-gateway/aws"
  version = "0.3.0"

  openapi_config = {
    openapi = "3.0.1"
    info = {
      title   = "foo" #var.api_gateway_title
      version = "v1"  #var.api_gateway_version
    }
    "paths" = {
      "/bossy/{proxy+}" = {
        "x-amazon-apigateway-any-method" = {
          "parameters" = [{
            "name"     = "proxy",
            "in"       = "path",
            "required" = true,
            "schema" = {
              "type" = "string"
            }
          }],
          "x-amazon-apigateway-integration" = {
            "httpMethod" = "POST",
            "uri"        = module.bossy_lambda.invoke_arn,
            "responses" = {
              "default" = {
                "statusCode" : "200"
              }
            },
            "passthroughBehavior" = "when_no_match",
            "contentHandling"     = "CONVERT_TO_TEXT",
            "type"                = "aws_proxy"
          }
        }
      }
    },
  }
  context = module.this.context
  depends_on = [
    module.api_gateway_account_settings
  ]
}

resource "aws_lambda_permission" "api_gw" {
  count         = local.enabled_count
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.label[0].id
  principal     = "apigateway.amazonaws.com"

  source_arn = format("%s/*/*/*", module.api_gateway.execution_arn)
}

resource "aws_ecr_pull_through_cache_rule" "bossy" {
  ecr_repository_prefix = "public-ecr"
  upstream_registry_url = "public.ecr.aws"
}

output "private_registry_id" {
  description = "The registry ID where the repository was created."
  value       = aws_ecr_pull_through_cache_rule.bossy.registry_id
}
