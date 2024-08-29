### IoT Things Group
output "iot_thing_group_arn" {
  description = "ARN of the IoT Things Group"
  value       = aws_iot_thing_group.thing_group.arn
}

# output var. provisioning_template_name
output "provisioning_template_name" {
  description = "Name of the provisioning template"
  value       = var.provisioning_template_name
}

### Certificate
output "claim_certificate_id" {
  description = "ID of the IoT Claim Certificate"
  value       = aws_iot_certificate.claim_certificate.id
}

output "claim_certificate_arn" {
  description = "ARN of the IoT Claim Certificate"
  value       = aws_iot_certificate.claim_certificate.arn
}

output "certificate_pem" {
  value       = aws_iot_certificate.claim_certificate.certificate_pem
  description = "The PEM-encoded certificate data"
  sensitive   = true
}

output "private_key" {
  value       = aws_iot_certificate.claim_certificate.private_key
  description = "The PEM-encoded private key data"
  sensitive   = true
}

output "public_key" {
  value       = aws_iot_certificate.claim_certificate.public_key
  description = "The PEM-encoded public key data"
}

# Greengrass token exchange role
output "greengrass_token_exchange_role_arn" {
  value       = aws_iam_role.greengrass_token_exchange_role.arn
  description = "ARN of the Greengrass Token Exchange Role"
}

output "greengrass_token_exchange_role_alias" {
  value       = aws_iot_role_alias.greengrass_token_exchange_role_alias.alias
  description = "Name of the Greengrass Token Exchange Role Alias"
}

### Endpoints
output "iot_data_endpoint" {
  value       = data.aws_iot_endpoint.iot_data_endpoint.endpoint_address
  description = "The IoT data endpoint"
}

output "iot_credential_provider_endpoint" {
 value       = data.aws_iot_endpoint.iot_credential_provider_endpoint.endpoint_address
 description = "The IoT credential provider endpoint"
}
