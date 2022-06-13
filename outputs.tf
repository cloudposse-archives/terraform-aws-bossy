output "base_url" {
  description = "Base URL for the Bossy's API Gateway."
  value       = module.api_gateway.invoke_url
}
