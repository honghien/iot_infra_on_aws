variable "iot_policy_name" {
  description = "Name of the IoT Policy."
}

variable "iot_thing_group_name" {
  description = "Name of the IoT Thing Group."
}

variable "fleet_provisioning_role_name" {
  description = "Name of the IAM role for Fleet Provisioning."
}

variable "provisioning_template_name" {
  description = "Name of the provisioning template."
}

variable "greengrass_token_exchange_role_name" {
  type        = string
  description = "Name of the Greengrass Token Exchange Role"
  default     = "my-greengrass-token-exchange-role"
}

variable "greengrass_token_exchange_role_alias" {
  type        = string
  description = "Alias for the Greengrass Token Exchange Role"
}

variable "aws_region" {
  description = "The AWS region to deploy resources in."
}
