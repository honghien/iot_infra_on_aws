output "greengrass_component_arns" {
  value = [
    aws_cloudformation_stack.greengrass_v2_stack.outputs["GreengrassCloudwatchMetricsComponentArn"],
    aws_cloudformation_stack.greengrass_v2_stack.outputs["GreengrassLogManagerComponentArn"],
    aws_cloudformation_stack.greengrass_v2_stack.outputs["GreengrassStreamManagerComponentArn"],
    aws_cloudformation_stack.greengrass_v2_stack.outputs["GreengrassDockerApplicationManagerComponentArn"],
    aws_cloudformation_stack.greengrass_v2_stack.outputs["CustomMLComponentArn"]
  ]
}


output "greengrass_deployment_command" {
  value = <<-EOT
    aws greengrassv2 create-deployment \
      --target-arn \
      "arn:aws:iot:${data.aws_region.current.name}:\
      ${data.aws_caller_identity.current.account_id}:\
      thinggroup/${var.iot_thing_group_name}" \
      --components \
      ${join(" ", formatlist("%s", aws_cloudformation_stack.greengrass_v2_stack.outputs["ComponentArns"]))} \
      --deployment-policies \
      failureHandlingPolicy=ROLLBACK_ON_FAILURE
    EOT
}

/*
  AWS ClI to initiate a deployment, and starts the deployment immediately after it is issued
    aws greengrassv2 create-deployment \
    --target-arn "arn:aws:iot:<region>:<account-id>:thinggroup/MyGreengrassGroup" \
    --components "com.example.MyComponent={ComponentVersion=1.0.0}" \
                "com.example.AnotherComponent={ComponentVersion=1.0.0}" \
    --deployment-policies failureHandlingPolicy=ROLLBACK_ON_FAILURE

  AWS CLI to get deployment status:
    aws greengrassv2 get-deployment --deployment-id <deployment-id>
    aws greengrassv2 get-deployment --deployment-id <deployment-id> --include-components
*/
