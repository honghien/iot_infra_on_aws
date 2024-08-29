### Claim Certificate ###
resource "aws_iot_certificate" "claim_certificate" {
  active = true
}

### IoT Policy ###
/*
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "iot:Connect",
          "iot:Publish",
          "iot:Subscribe",
          "iot:Receive"
        ],
        "Resource": "*"
      }
    ]
  }
*/
resource "aws_iot_policy" "iot_policy" {
  name   = var.iot_policy_name
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "iot:*",
      "Resource": "*"
    }
  ]
}
POLICY
}

### Attach IoT policy to Cert ###
resource "aws_iot_policy_attachment" "attach_policy_to_cert" {
  policy = aws_iot_policy.iot_policy.name
  target = aws_iot_certificate.claim_certificate.arn
}

### IoT Thing Group ###
resource "aws_iot_thing_group" "thing_group" {
  name = var.iot_thing_group_name
}

### Create IoT Thing & add to group ###

# resource "aws_iot_thing" "thing" {
#   name = var.iot_thing_name
# }

# resource "aws_iot_thing_group_membership" "thing_group_membership" {
#   thing_group_name = aws_iot_thing_group.thing_group.name
#   thing_name       = aws_iot_thing.thing.name
# }

### IAM Role for Fleet Provisioning, got referred in aws_iot_provisioning_template ###
data "aws_iam_policy_document" "fleet_provisioning_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["iot.amazonaws.com"] # Represent IoT Core service
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "fleet_provisioning_role" {
  name = var.fleet_provisioning_role_name

  assume_role_policy = data.aws_iam_policy_document.fleet_provisioning_assume_role_policy.json
}

data "aws_iam_policy_document" "fleet_provisioning_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "iot:CreateThing",
      "iot:CreateKeysAndCertificate",
      "iot:AttachPolicy",
      "iot:AttachThingPrincipal"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "fleet_provisioning_role_policy" {
  role = aws_iam_role.fleet_provisioning_role.id

  policy = data.aws_iam_policy_document.fleet_provisioning_role_policy.json
}


/*
- GGTokenExchangeRole
    * an IAM role,

    * When you deploy AWS IoT Greengrass components or Lambda functions to a Greengrass core device, 
    these components and functions may need to interact with other AWS services, 
    such as Amazon S3, Amazon DynamoDB, or AWS IoT Core
    on behalf of the components and functions running on the device

    * Step 1 - When a Greengrass core device needs to interact with AWS services, 
    such as S3, DynamoDB, or Lambda, it assumes the Greengrass Token Exchange Role
    * Step 2 - The Greengrass core uses STS to exchange the Greengrass Token Exchange Role 
    for temporary security credentials
    * Step 3 - Core device use the credential to interact with AWS services 
    within the permissions specified by the role

    * This role is created in the provisioning template, 
    & used in the provisioning template to allow the Greengrass core device

  - [optional] Core device role attached to thing to allow interaction with other AWS services (not IoT core)

*/
resource "aws_iam_role" "greengrass_token_exchange_role" {
  name = var.greengrass_token_exchange_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "credentials.iot.amazonaws.com" # endpoint for AWS IoT Core Credential Provider
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "greengrass_token_exchange_policy" {
  name = "${var.greengrass_token_exchange_role_name}-policy"
  role = aws_iam_role.greengrass_token_exchange_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iot:DescribeCertificate",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "iot:Connect",
          "iot:Publish",
          "iot:Subscribe",
          "iot:Receive",
          "s3:GetBucketLocation"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iot_role_alias" "greengrass_token_exchange_role_alias" {
  alias    = var.greengrass_token_exchange_role_alias
  role_arn = aws_iam_role.greengrass_token_exchange_role.arn
}

### Fleet Provisioning Template ###
/*
- DeviceCertificate refers to the certificate that the device presents during provisioning, 
  which is typically the claim certificate. 
  A new certificate is created in AWS IoT Core using the claim certificate 
  and associated with the IoT Thing being created for each device in the fleet
- AWS::IoT::Certificate::ThingName refers to the name of the IoT Thing 
  that will be automatically created and associated with the newly created certificate in AWS IoT Core

- No need to attach iot policy to certificate again as it has been attached to claim certificate
"Attachments": {
    "AttachPolicy": {
      "Id": "AttachPolicy",
      "Target": {
        "Ref": "certificate"
      },
      "PolicyName": "${aws_iot_policy.iot_policy.name}"
    }
  }
*/
resource "aws_iot_provisioning_template" "provisioning_template" {
  name                 = var.provisioning_template_name
  provisioning_role_arn = aws_iam_role.fleet_provisioning_role.arn

  template_body = <<JSON
{
  "Parameters": {
    "DeviceCertificate": {
      "Type": "String"
    }
  },
  "Resources": {
    "thing": {
      "Type": "AWS::IoT::Thing",
      "Properties": {
        "ThingName": {"Ref": "AWS::IoT::Certificate::ThingName"}
        "ThingGroups": ["${aws_iot_thing_group.thing_group.name}"]
      }
    },
    "certificate": {
      "Type": "AWS::IoT::Certificate",
      "Properties": {
        "CertificatePem": {"Ref": "DeviceCertificate"},
        "Status": "ACTIVE"
      }
    }
  }
}
JSON
}

### IoT endpoint (shared among both IoT Core & Greengrass) ###
data "aws_iot_endpoint" "iot_data_endpoint" {
  /*
  - iot:Data-ATS: The AWS IoT Data-ATS endpoint, 
    used for connecting devices to AWS IoT Core/Greengrass for data communication.

    E.g. <endpoint-id>-ats.iot.<region>.amazonaws.com

  - iot:CredentialProvider: 
    Used for obtaining temporary security credentials for devices.

    E.g. <endpoint-id>.credentials.iot.<region>.amazonaws.com

  - iot:Jobs: Endpoint for managing and executing IoT jobs, 
    which allows you to send remote commands to devices.

    E.g. <endpoint-id>.jobs.iot.<region>.amazonaws.com
  */
  endpoint_type = "iot:Data-ATS"
}

data "aws_iot_endpoint" "iot_credential_provider_endpoint" {
  endpoint_type = "iot:CredentialProvider"
}

