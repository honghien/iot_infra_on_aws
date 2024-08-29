data "aws_region" "current" {}
data "aws_caller_identity" "current" {}


### Greengrass Service Role ###
data "aws_iam_policy_document" "greengrass_service_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["greengrass.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "greengrass_service_role" {
  name = var.greengrass_service_role_name

  assume_role_policy = data.aws_iam_policy_document.greengrass_service_assume_role_policy.json
}

data "aws_iam_policy_document" "greengrass_service_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction",
      "s3:GetObject",
      "s3:PutObject",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "greengrass_service_role_policy" {
  role = aws_iam_role.greengrass_service_role.id

  policy = data.aws_iam_policy_document.greengrass_service_role_policy.json
}

# Associate greengrass_service_role to account
# not supported by terraform AWS provider, so AWS CLI is used (Cloudformation can be used as well)
resource "null_resource" "associate_greengrass_service_role" {
  provisioner "local-exec" {
    command = "aws greengrassv2 associate-service-role-to-account --role-arn ${aws_iam_role.greengrass_service_role.arn}"
  }

  depends_on = [aws_iam_role.greengrass_service_role]
}


### CloudFormation Stack for Greengrass v2 Components ###
/*
  1 - Create Greengrass component version, with Recipe & Artifacts registered.
    NOT execute/deploy/affect on edge devices yet.

  [QUESTION] confirm on components & their usage on edge device
  => Toan: public & default
  [QUESTION] how to test components & their subscription/integration locally before deploying to cloud
  => Toan: 
  [QUESTION] how to test execution of CloudFormation yaml file
*/
resource "aws_cloudformation_stack" "greengrass_v2_stack" {
  name          = "GreengrassV2Stack"
  template_body = file("${path.module}/templates/greengrass_v2.yaml")

  parameters = {
    KinesisStreamName = var.kinesis_stream_name
    KinesisRegion     = var.kinesis_region

    CustomMLComponentName      = var.custom_ml_component_name
    CustomMLComponentVersion   = var.custom_ml_component_version
  }

  capabilities = ["CAPABILITY_NAMED_IAM"]
}
