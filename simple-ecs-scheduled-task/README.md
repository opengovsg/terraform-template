# Simple ECS Scheduled Task
This repository sets up a simple ECS scheduled task for demo purposes.

## Getting started
Before you start anything, you need to create a new Terraform workspace. A workspace allows us to separate different environments (such as dev, staging, prod etc.) and stores important information on the state of your infra. To get started, we'll create a workspace for local development. Run the following command:

```
terraform workspace new development
```

When deploying to staging or production, make sure that the necessary workspaces are created before switching to them.

```
terraform workspace new staging
terraform workspace select staging
```

### Prerequisites
Copy the set of files in this repository into a new project-specific folder. You will also need an AWS account with a set of API credentials that has sufficient permissions.

For this project, you will also need to ensure that either your AWS account has a service-linked role for AWS ECS. This is because the Amazon ECS container agent makes calls to the Amazon ECS API actions on our behalf, so container instances that run the agent require the ecsInstanceRole IAM policy and role for the service to know that the agent belongs to you. For more information, refer to the [AWS docs](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using-service-linked-roles.html#create-service-linked-role).

(WIP) I am still in the process of figuring out the correct IAM roles needed for this. In the meantime, attach the `IAMFullAccess` policy to your IAM user for this to work.

This is needed by the ECS scheduled task module to create the roles needed to create CloudWatch Eventbridge events.

### Configuration
Create a new file named `.tfvars` in the project directory with the following contents:

```txt
aws_profile="<your aws profile name>"
allowed_account_id="<your aws account id>"
app_name="<your app name>"
capacity_providers=["FARGATE"]
image="<image to be deployed>"
scheduled_task_description="This is a simple ECS scheduled task"
scheduled_task_schedule_expression="rate(5 minutes)"
scheduled_task_target_security_groups=[<your VPC's default security group>]
scheduled_task_target_subnets=[<your VPC's public subnet-1>, <your VPC's public subnet-2>]
```

Refer to the `variables.tf` file for more information. Note: this project assumes that you have installed the `aws-cli` and have set up local AWS profiles that you can reference.

### Instructions
To run Terraform to deploy our ECS, please follow the following steps.

#### Initialization
Before you can run any Terraform commands to set up infrastructure, you'll need to first initialize your Terraform working directory. This will install the necessary modules for your working directory. Run the following command:

```zsh
terraform init
```

You should see a stream of logs in your console. Once the initialization is successful, you should see the line `Terraform has been successfully initialized!`.

#### Terraform configuration validation
Once that is done, we want to validate that our Terraform configuration does not contain any erroneous syntax. Run the following command:

```zsh
terraform validate
```

On success, you should see the log `Success! The configuration is valid.`.

#### Dry run
Before we actually create any resources, we want to make sure that our Terraform configuration is doing what we want. Run the following command:

```zsh
terraform plan -var-file=<path to your .tfvars file>
```

This will print out Terraform's execution plan (the actions that Terraform will take on AWS) given the Terraform configuration file and the current state of your Terraform project. You can expect the logs printed by Terraform to end with a summary line which sums up the changes. An example summary line might be `Plan: 2 to add, 0 to change, 0 to destroy.`.

As a precaution, always remember to run `terraform plan` before you go ahead with your execution plan.

#### Execute
To go ahead and create the resources, run the following command:

```zsh
terraform apply -var-file=<path to your .tfvars file>
```

#### Teardown
Run the following command to remove all created infrastructure:

```zsh
terraform destroy -var-file=".tfvars"
```


