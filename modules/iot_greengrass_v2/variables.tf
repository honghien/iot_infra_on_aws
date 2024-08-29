# device, thing
variable "iot_thing_group_name" {
  description = "Name of the IoT Thing Group for Greengrass Core devices."
}

# service role
variable "greengrass_service_role_name" {
  description = "Name of the IAM role for Greengrass service."
}

# custom ml component
variable "custom_ml_component_name" {
  description = "Name of the custom ML component."
}

variable "custom_ml_component_version" {
  description = "Version of the custom ML component."
}

variable "kinesis_stream_name" {
  description = "The name of the target Kinesis Data Stream"
  type        = string
}

variable "kinesis_region" {
  description = "The region of the Kinesis Data Stream"
  type        = string
}

# common
variable "aws_region" {
  description = "The AWS region to deploy resources in."
}
