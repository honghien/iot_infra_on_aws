# Setup edge device: https://github.com/huynhbaotoan/iotgreengrass-edge/blob/main/README.md 
/*
  Step by step to configure and start Greengrass Edge Device With Fleet Provisioning
    - Claim certificate
      + Download from IoT Core & transfer to claim certificate and private key files to edge device
      
    - Greengrass Token Exchange Role
      + Create a Token Exchange IAM Role
      + create a role alias that points to the token exchange role

    - config.yaml
        rootPath: "/greengrass/v2"
        awsRegion: "<your-aws-region>"

        provisioningTemplate: "<your-provisioning-template>"

        iotDataEndpoint: "<your-iot-data-endpoint>" // claim certificate file
        iotCredentialEndpoint: "<your-iot-credential-endpoint>" //certificate file

        iotRoleAlias: "<your-role-alias>"
        
    -  Install  Greengrass Core software with fleet provisioning on Edge device
        sudo -E java -Droot="/greengrass/v2" -Dlog.store=FILE -jar 

        ./GreengrassInstaller/lib/Greengrass.jar --trusted-plugin 

        ./GreengrassInstaller/aws.greengrass.FleetProvisioningByClaim.jar 
          --init-config ./GreengrassInstaller/config.yaml 
          --component-default-user ggc_user:ggc_group 
          --setup-system-service true

    - Start the Greengrass Core Software
      It should automatically attempt to provision itself using the claim certificate 
      and the settings defined in your configuration file.
      It should appear under the Things section in AWS IoT Console.

        sudo systemctl start greengrass.service
*/

# [QUESTION] After "terraform plan/apply (--dry-run)", how to quick validate the deployment

provider "aws" {
  region = var.aws_region
}

module "iot_core" {
  source = "../../modules/iot_core"

  iot_thing_group_name         = var.iot_thing_group_name

  iot_policy_name              = var.iot_policy_name
  
  fleet_provisioning_role_name = var.fleet_provisioning_role_name
  provisioning_template_name   = var.provisioning_template_name

  greengrass_token_exchange_role_name = var.greengrass_token_exchange_role_name
  greengrass_token_exchange_role_alias = var.greengrass_token_exchange_role_alias

  aws_region                   = var.aws_region
}

module "iot_greengrass_v2" {
  source = "../../modules/iot_greengrass_v2"

  iot_thing_group_name = var.iot_thing_group_name

  greengrass_service_role_name = var.greengrass_service_role_name
  
  custom_ml_component_name     = var.custom_ml_component_name
  custom_ml_component_version  = var.custom_ml_component_version
  
  aws_region                   = var.aws_region
  kinesis_stream_name          = var.kinesis_stream_name
  kinesis_region               = var.kinesis_region
}
