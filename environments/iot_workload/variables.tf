variable "aws_region" {
  description = "The AWS region to deploy resources in."
  default   = "ap-southeast-1"  # You can change the default value to your preferred region (ap-southeast-2: Sydney)
}

variable "iot_policy_name" {
  description = "Name of the IoT Policy."
  default = "iot-policy-name"
}

variable "iot_thing_group_name" {
  description = "Name of the IoT Thing Group."
  default = "iot-thing-group-name"
}

variable "fleet_provisioning_role_name" {
  description = "Name of the IAM role for Fleet Provisioning."
  default = "iot-fleet-provisioning-role-vinamilk"
}

variable "provisioning_template_name" {
  description = "Name of the provisioning template."
  default = "iot-provisioning-template-vinamilk"
}

variable "greengrass_service_role_name" {
  description = "Name of the IAM role for Greengrass service."
}

variable "greengrass_token_exchange_role_name" {
  type        = string
  description = "The name of the Greengrass token exchange role"
  default     = "my-greengrass-token-exchange-role"
}

variable "greengrass_token_exchange_role_alias" {
  type        = string
  description = "The alias for the Greengrass token exchange role"
}

variable "custom_ml_component_name" {
  description = "Name of the custom ML component."
}

variable "custom_ml_component_version" {
  description = "Version of the custom ML component."
}

variable "kinesis_stream_name" {
  description = "The name of the target Kinesis Data Stream"
  type        = string
  default     = "my-kinesis-stream"
}

variable "kinesis_region" {
  description = "The region of the Kinesis Data Stream"
  type        = string
  default     = "us-west-2"
}
